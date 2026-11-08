// Table-driven tests: each test is a list of cases (a slice of anonymous structs) and one loop.
// Adding a case is one line. t.Run gives each case its own name in the output.
//
//	go test ./...                  from go/: every test
//	go test -tags bug12 ./concepts lesson 12's swallowed error, caught here by TestParseTasks

package main

import (
	"cmp"
	"errors"
	"math"
	"slices"
	"strings"
	"testing"
)

func TestCleanStatus(t *testing.T) {
	cases := []struct{ in, want string }{
		{"[done]", "done"}, {"[done.]", "done"}, {"[DONE]", "done"}, {"[ todo ]", "todo"}, {"[]", ""},
	}
	for _, c := range cases {
		if got := cleanStatus(c.in); got != c.want {
			t.Errorf("cleanStatus(%q) = %q, want %q", c.in, got, c.want)
		}
	}
}

func TestParseTask(t *testing.T) {
	cases := []struct {
		line    string
		want    string // how the Task prints
		wantErr error
	}{
		{"[done.] Call mom #family", "[done] Call mom #family", nil},
		{"[ todo ] Review pull request #work.", "[todo] Review pull request #work", nil},
		{"[doing] Write tests #Work", "[other] Write tests #work", nil},
		{"remember milk", "", ErrNotTask},
		{"", "", ErrNotTask},
		{"[todo]", "", ErrNoTitle},
	}
	for _, c := range cases {
		t.Run(c.line, func(t *testing.T) {
			task, err := parseTask(c.line)
			if !errors.Is(err, c.wantErr) {
				t.Fatalf("error %v, want %v", err, c.wantErr)
			}
			if err == nil && task.String() != c.want {
				t.Errorf("got %q, want %q", task.String(), c.want)
			}
		})
	}
}

func TestParseTasks(t *testing.T) {
	cases := []struct {
		name    string
		lines   []string
		titles  []string
		wantErr error
	}{
		{"skips blanks and notes", []string{"[todo] A", "", "a note", "[done] B"}, []string{"A", "B"}, nil},
		{"stops at a task with no title", []string{"[todo] A", "[todo]"}, nil, ErrNoTitle},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			tasks, err := parseTasks(c.lines)
			if !errors.Is(err, c.wantErr) {
				t.Fatalf("error %v, want %v", err, c.wantErr)
			}
			var titles []string
			for _, task := range tasks {
				titles = append(titles, task.Title)
			}
			if !slices.Equal(titles, c.titles) {
				t.Errorf("titles %q, want %q", titles, c.titles)
			}
		})
	}
}

func TestReadTasksAndCount(t *testing.T) {
	text := "[done] Buy groceries #home\n[todo] Finish report #work #urgent\n\n[DONE] Fix bug #work\n"
	tasks, err := readTasks(strings.NewReader(text)) // any io.Reader will do: no file needed
	if err != nil {
		t.Fatal(err)
	}
	var tagLists [][]string
	for _, task := range tasks {
		tagLists = append(tagLists, task.Tags)
	}
	order, counts := countTags(tagLists)
	if want := []string{"home", "work", "urgent"}; !slices.Equal(order, want) {
		t.Errorf("order %q, want %q", order, want)
	}
	if counts["work"] != 2 {
		t.Errorf("work counted %d times, want 2", counts["work"])
	}
}

func TestTopNKeepsTiesInOrder(t *testing.T) {
	in := []TagCount{{"home", 2}, {"work", 3}, {"urgent", 1}, {"family", 1}, {"travel", 1}}
	got := TopN(in, 4, mostFirst)
	want := []TagCount{{"work", 3}, {"home", 2}, {"urgent", 1}, {"family", 1}}
	if !slices.Equal(got, want) {
		t.Errorf("got %v, want %v", got, want)
	}
	if in[0].Tag != "home" {
		t.Error("TopN changed the caller's slice")
	}
	if got := TopN([]int{3, 1}, 5, cmp.Compare[int]); !slices.Equal(got, []int{1, 3}) {
		t.Errorf("n past the end: got %v", got)
	}
}

func TestRoundingMatchesPython(t *testing.T) {
	cases := []struct{ in, want float64 }{{0.5, 0}, {1.5, 2}, {2.5, 2}, {62.5, 62}, {33.4, 33}}
	for _, c := range cases {
		if got := math.RoundToEven(c.in); got != c.want {
			t.Errorf("RoundToEven(%v) = %v, want %v (Python's round)", c.in, got, c.want)
		}
	}
}
