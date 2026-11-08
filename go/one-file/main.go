// The task tracker in one Go file. Same prompts, summary and chart as the Python version, byte for
// byte: contract/run.sh checks every one. Read top to bottom: settings, what a task is, parsing a
// line, the file, counting and ranking, the chart, then main, the only part that talks to the user.
//
//	cd go
//	go build -o one-file/build/tracker ./one-file      build it
//	contract/run.sh "$PWD/one-file/build/tracker"      (from the repo root) the contract
//	go vet ./... && gofmt -l .                         must say nothing
package main

import (
	"bufio"
	"cmp"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"math"
	"os"
	"slices"
	"strings"
)

// ---- Settings ---------------------------------------------------------------------------------

const (
	chartWidth = 20  // the longest bar, in characters
	defaultTop = 3   // top tags shown when the answer is empty or invalid
	tagMarker  = "#" // marks a word as a tag: "#work"
	bar        = "█"
)

// ---- What a task is ---------------------------------------------------------------------------

// Status is a small named type, and iota numbers its values. Go has no enum keyword: this is the enum.
type Status int

const (
	Todo Status = iota
	Done
	Other // a status we didn't recognise; Task.StatusWord keeps the word
)

// Kind replaces Python's UrgentTask subclass: Go has no inheritance.
type Kind int

const (
	Plain Kind = iota
	Urgent
)

type Task struct {
	Title      string
	Tags       []string
	Status     Status
	StatusWord string // the cleaned word between the brackets, for any status
	Kind       Kind
}

func (t Task) IsDone() bool { return t.Status == Done }

// String makes Task a fmt.Stringer: Println(task) prints "[ ] Title", "  !!" on the end of an urgent one.
// No "implements" anywhere: having the method is enough.
func (t Task) String() string {
	mark, urgent := " ", ""
	if t.IsDone() {
		mark = "x"
	}
	if t.Kind == Urgent {
		urgent = "  !!"
	}
	return "[" + mark + "] " + t.Title + urgent
}

// ---- Parsing one line -------------------------------------------------------------------------

// parseLine turns "[done.] Call mom #family" into a Task. The second result says whether the line
// was a task at all: Go's comma-ok, where Python returned None.
func parseLine(line string) (Task, bool) {
	s := strings.TrimSpace(line)
	if !strings.HasPrefix(s, "[") {
		return Task{}, false
	}
	raw, rest, _ := strings.Cut(s, "]") // Python's partition("]")
	word := strings.ToLower(strings.Trim(raw, "[] ."))
	status := Other
	switch word {
	case "done":
		status = Done
	case "todo":
		status = Todo
	}
	var title, tags []string
	kind := Plain
	for _, w := range strings.Fields(rest) {
		if !strings.HasPrefix(w, tagMarker) {
			title = append(title, w)
			continue
		}
		tag := strings.ToLower(strings.Trim(strings.TrimLeft(w, tagMarker), ".,"))
		tags = append(tags, tag)
		if tag == "urgent" {
			kind = Urgent
		}
	}
	return Task{Title: strings.Join(title, " "), Tags: tags, Status: status, StatusWord: word, Kind: kind}, true
}

// ---- The file ---------------------------------------------------------------------------------

// loadTasks returns every task in the file; lines that aren't tasks are skipped. An error comes
// back as a value, wrapped with %w so the caller can still ask errors.Is what it was underneath.
func loadTasks(path string) ([]Task, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, fmt.Errorf("load tasks: %w", err)
	}
	defer f.Close() // however this function returns
	var tasks []Task
	lines := bufio.NewScanner(f) // one line at a time, "\r\n" endings handled
	lines.Buffer(make([]byte, 64*1024), 16*1024*1024)
	for lines.Scan() {
		if task, ok := parseLine(lines.Text()); ok {
			tasks = append(tasks, task)
		}
	}
	if err := lines.Err(); err != nil {
		return nil, fmt.Errorf("load tasks: %w", err)
	}
	return tasks, nil
}

// addTasks parses each title as a new "[todo]" task and adds it. It returns the longer slice and
// how many were added: append may move the slice, so the caller must use the one it gets back.
func addTasks(tasks []Task, titles []string) ([]Task, int) {
	added := 0
	for _, title := range titles {
		if task, ok := parseLine("[todo] " + title); ok {
			tasks = append(tasks, task)
			added++
		}
	}
	return tasks, added
}

// appendTitles writes "[todo] title" lines on the end of the file.
func appendTitles(path string, titles []string) error {
	f, err := os.OpenFile(path, os.O_APPEND|os.O_WRONLY, 0)
	if err != nil {
		return err
	}
	w := bufio.NewWriter(f)
	for _, title := range titles {
		fmt.Fprintf(w, "[todo] %s\n", title)
	}
	if err := w.Flush(); err != nil {
		f.Close()
		return err
	}
	return f.Close() // a write can fail at close too, so its error counts
}

// ---- Counting and ranking ---------------------------------------------------------------------

type TagCount struct {
	Tag   string
	Count int
}

// countTags counts every tag, in the order each first appears. A map finds a tag's place fast, but
// ranging over a map gives a different order every run, so the slice keeps the order.
func countTags(tasks []Task, includeDone bool) []TagCount {
	var counts []TagCount
	place := map[string]int{}
	for _, task := range tasks {
		if !includeDone && task.IsDone() {
			continue
		}
		for _, tag := range task.Tags {
			i, seen := place[tag]
			if !seen {
				i = len(counts)
				place[tag] = i
				counts = append(counts, TagCount{Tag: tag})
			}
			counts[i].Count++
		}
	}
	return counts
}

// topN is generic: the n items with the biggest key, biggest first, for any type T. SortStableFunc
// is stable, so items with the same key keep their order.
func topN[T any](items []T, n int, key func(T) int) []T {
	sorted := slices.Clone(items)
	slices.SortStableFunc(sorted, func(a, b T) int { return cmp.Compare(key(b), key(a)) })
	return sorted[:min(n, len(sorted))]
}

// ErrNeedAtLeastOne is a sentinel error: one value, compared with errors.Is. Python's ValueError.
var ErrNeedAtLeastOne = errors.New("need at least 1 top tag")

func topTags(tasks []Task, n int, includeDone bool) ([]TagCount, error) {
	if n < 1 {
		return nil, ErrNeedAtLeastOne
	}
	return topN(countTags(tasks, includeDone), n, func(c TagCount) int { return c.Count }), nil
}

// ---- The chart --------------------------------------------------------------------------------

// drawChart draws to any io.Writer: the screen here, a buffer in a test.
func drawChart(w io.Writer, pairs []TagCount, width int) {
	if len(pairs) == 0 {
		fmt.Fprintln(w, "No tags yet.")
		return
	}
	biggest := float64(pairs[0].Count)
	labelWidth := 0
	for _, p := range pairs {
		labelWidth = max(labelWidth, len([]rune(p.Tag)))
	}
	for _, p := range pairs {
		// RoundToEven is Python's round(); %-*s pads by runes, as Python pads by characters.
		blocks := int(math.RoundToEven(float64(p.Count) / biggest * float64(width)))
		fmt.Fprintf(w, "%-*s  %s %d\n", labelWidth, p.Tag, strings.Repeat(bar, blocks), p.Count)
	}
}

// ---- Talking to the user ----------------------------------------------------------------------

var stdin = bufio.NewReader(os.Stdin)

// ask is Python's input(): shows the prompt, reads one line. An empty line at the end of input.
func ask(prompt string) string {
	fmt.Print(prompt)
	line, _ := stdin.ReadString('\n') // at the end of input: what was there, and io.EOF
	return strings.TrimSuffix(line, "\n")
}

// parseWholeNumber is Python's int(text): optional spaces, an optional sign, digits with single
// underscores between them, optional spaces. strconv.Atoi takes no spaces or underscores, so it's
// written here. Huge numbers are capped.
func parseWholeNumber(text string) (int, bool) {
	s := strings.TrimSpace(text)
	negative := false
	if s != "" && (s[0] == '-' || s[0] == '+') {
		negative, s = s[0] == '-', s[1:]
	}
	if s == "" || s[0] < '0' || s[0] > '9' {
		return 0, false
	}
	value := 0
	for i := 0; i < len(s); i++ {
		c := s[i]
		if c == '_' && i+1 < len(s) && s[i+1] >= '0' && s[i+1] <= '9' && s[i-1] != '_' {
			continue
		}
		if c < '0' || c > '9' {
			return 0, false
		}
		value = min(value*10+int(c-'0'), math.MaxInt32)
	}
	if negative {
		value = -value
	}
	return value, true
}

func main() {
	path, set := os.LookupEnv("TASKS_FILE") // set but empty is still set, as in Python
	if !set {
		path = "tasks.txt"
	}
	if len(os.Args) > 1 {
		path = os.Args[1]
	}

	tasks, err := loadTasks(path)
	if errors.Is(err, fs.ErrNotExist) {
		fmt.Fprintf(os.Stderr, "Couldn't find %s\n", path)
		os.Exit(1)
	} else if err != nil {
		fmt.Fprintf(os.Stderr, "Couldn't read %s\n", path)
		os.Exit(1)
	}

	var newTitles []string
	for {
		title := strings.TrimSpace(ask("New task (Enter to finish): "))
		if title == "" {
			break
		}
		if strings.HasPrefix(title, tagMarker) {
			fmt.Println("A task needs a title, not just tags.")
			continue
		}
		newTitles = append(newTitles, title)
	}
	tasks, added := addTasks(tasks, newTitles)
	if added > 0 {
		if err := appendTitles(path, newTitles); err != nil {
			fmt.Fprintf(os.Stderr, "Couldn't write %s\n", path)
			os.Exit(1)
		}
	}

	n := defaultTop
	if answer := ask("How many top tags? [3]: "); answer != "" {
		n, _ = parseWholeNumber(answer) // not a number: 0, which topTags refuses
	}
	pairs, err := topTags(tasks, n, true)
	if errors.Is(err, ErrNeedAtLeastOne) {
		fmt.Println("Need a whole number of at least 1 — using 3.")
		pairs, _ = topTags(tasks, defaultTop, true)
	}

	done := 0
	for _, t := range tasks {
		if t.IsDone() {
			done++
		}
	}
	percent := 0.0
	if len(tasks) > 0 {
		percent = float64(done) / float64(len(tasks)) * 100
	}
	fmt.Printf("\n%d tasks, %d done (%.0f%%), %d tags\n", len(tasks), done, percent, len(countTags(tasks, true)))
	for _, t := range tasks {
		if t.Kind == Urgent && !t.IsDone() {
			fmt.Println(t)
		}
	}

	fmt.Println("\nTop tags")
	drawChart(os.Stdout, pairs, chartWidth)
}
