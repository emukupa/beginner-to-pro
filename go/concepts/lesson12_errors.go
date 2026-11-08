// Lesson 12: in Go an error is just a value, returned last, and checked with if err != nil.
// Sentinel errors name a kind of failure; %w wraps one with more detail; errors.Is finds it again
// through the wrapping. Panics are for bugs, not for bad input.
// -tags bug12: parseTasks ignores parseTask's error with _. It builds and runs; the test fails.

package main

import (
	"errors"
	"fmt"
)

// Sentinel errors: made once, compared by identity. The Err prefix is the Go convention.
var (
	ErrNotTask = errors.New("not a task line")
	ErrNoTitle = errors.New("task has no title")
)

// parseTask turns one line into a Task, using lesson 06's splitLine and lesson 09's parseStatus.
// The error wraps a sentinel with %w, so callers can still ask which one it was.
func parseTask(line string) (Task, error) {
	status, title, tags, ok := splitLine(line)
	if !ok {
		return Task{}, fmt.Errorf("%w: %q", ErrNotTask, line)
	}
	if title == "" {
		return Task{}, fmt.Errorf("%w: %q", ErrNoTitle, line)
	}
	return Task{Title: title, Status: parseStatus(status), Tags: tags}, nil
}

// safely runs f and turns a panic into an error. defer runs when the function returns, even when
// it's leaving because of a panic; recover, called there, stops the panic.
func safely(f func()) (err error) {
	defer func() {
		if r := recover(); r != nil {
			err = fmt.Errorf("recovered: %v", r) // err is the named result, so this sets what's returned
		}
	}()
	f()
	return nil
}

func lesson12() {
	for _, line := range []string{"[done.] Call mom #family", "remember milk", "[todo]"} {
		task, err := parseTask(line)
		switch {
		case err == nil:
			fmt.Println("ok:      ", task)
		case errors.Is(err, ErrNotTask): // == would fail: err wraps ErrNotTask, it isn't ErrNotTask
			fmt.Println("skipped: ", err)
		default:
			fmt.Println("problem: ", err, "| is ErrNoTitle?", errors.Is(err, ErrNoTitle))
		}
	}

	wrapped := fmt.Errorf("line 3: %w", fmt.Errorf("%w: %q", ErrNoTitle, "[todo]")) // wraps can nest
	fmt.Println(wrapped, "| still ErrNoTitle?", errors.Is(wrapped, ErrNoTitle))

	tasks, err := parseTasks([]string{"[todo] Pay rent", "", "a note", "[done] Walk dog"})
	fmt.Printf("parseTasks: %d tasks, err %v\n", len(tasks), err)
	_, err = parseTasks([]string{"[todo] Pay rent", "[todo]"})
	fmt.Println("parseTasks:", err)

	err = safely(func() {
		var tags []string
		fmt.Println(tags[0]) // a bug, so Go panics instead of returning an error
	})
	fmt.Println("safely:", err)
	bug(12)
}
