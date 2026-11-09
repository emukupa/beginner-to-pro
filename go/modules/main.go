// The task tracker, split into packages: one folder per job under internal/, and this file, the
// only one that reads input, prints to the screen or exits.
//
// internal/ is a Go rule, not a convention: only code inside go/modules can import those packages.
// Dependencies point one way: models <- parsing <- storage, tasklist <- chart <- main. Go refuses
// an import cycle outright, so they can't point any other way.
//
//	cd go
//	go build -o modules/build/tracker ./modules
//	go test ./modules/...
package main

import (
	"bufio"
	"errors"
	"fmt"
	"io/fs"
	"math"
	"os"
	"strings"

	"github.com/emukupa/beginner-to-pro/go/modules/internal/chart"
	"github.com/emukupa/beginner-to-pro/go/modules/internal/models"
	"github.com/emukupa/beginner-to-pro/go/modules/internal/parsing"
	"github.com/emukupa/beginner-to-pro/go/modules/internal/storage"
	"github.com/emukupa/beginner-to-pro/go/modules/internal/tasklist"
)

const defaultTop = 3 // top tags shown when the answer is empty or invalid

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

// doneCommand runs "tracker done title": it marks one task finished, and returns the exit code.
func doneCommand(words []string) int {
	title := strings.TrimSpace(strings.Join(words, " "))
	if title == "" {
		fmt.Fprintln(os.Stderr, `Usage: done "task title"`)
		return 2
	}
	path, set := os.LookupEnv("TASKS_FILE")
	if !set {
		path = "tasks.txt"
	}
	tasks, err := storage.Load(path)
	if errors.Is(err, fs.ErrNotExist) {
		fmt.Fprintf(os.Stderr, "Couldn't find %s\n", path)
		return 1
	} else if err != nil {
		fmt.Fprintf(os.Stderr, "Couldn't read %s\n", path)
		return 1
	}
	task := tasklist.Find(tasks, title)
	if task == nil {
		fmt.Fprintf(os.Stderr, "No task called \"%s\"\n", title) // not %q: that would escape quotes inside
		return 1
	}
	if task.IsDone() {
		fmt.Printf("Already done: %s\n", task.Title)
		return 0
	}
	if err := storage.MarkDone(path, *task); err != nil {
		fmt.Fprintf(os.Stderr, "Couldn't write %s\n", path)
		return 1
	}
	fmt.Printf("Done: %s\n", task.Title)
	return 0
}

func main() {
	if len(os.Args) > 1 && os.Args[1] == "done" { // a second mode: tracker done "title"
		os.Exit(doneCommand(os.Args[2:]))
	}

	path, set := os.LookupEnv("TASKS_FILE") // set but empty is still set, as in Python
	if !set {
		path = "tasks.txt"
	}
	if len(os.Args) > 1 {
		path = os.Args[1]
	}

	tasks, err := storage.Load(path)
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
		if strings.HasPrefix(title, parsing.TagMarker) {
			fmt.Println("A task needs a title, not just tags.")
			continue
		}
		newTitles = append(newTitles, title)
	}
	tasks, added := tasklist.Add(tasks, newTitles)
	if added > 0 {
		if err := storage.AppendTitles(path, newTitles); err != nil {
			fmt.Fprintf(os.Stderr, "Couldn't write %s\n", path)
			os.Exit(1)
		}
	}

	n := defaultTop
	if answer := ask("How many top tags? [3]: "); answer != "" {
		n, _ = parseWholeNumber(answer) // not a number: 0, which TopTags refuses
	}
	pairs, err := tasklist.TopTags(tasks, n, true)
	if errors.Is(err, tasklist.ErrNeedAtLeastOne) {
		fmt.Println("Need a whole number of at least 1 — using 3.")
		pairs, _ = tasklist.TopTags(tasks, defaultTop, true)
	}

	s := tasklist.Summarize(tasks)
	fmt.Printf("\n%d tasks, %d done (%.0f%%), %d tags\n", s.Total, s.Done, s.Percent, s.Tags)
	for _, t := range tasks {
		if t.Kind == models.Urgent && !t.IsDone() {
			fmt.Println(t)
		}
	}

	fmt.Println("\nTop tags")
	chart.Draw(os.Stdout, pairs, chart.Width)
}
