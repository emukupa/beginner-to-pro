// Lesson 13: open a file, defer its Close straight away, read it line by line with bufio.Scanner,
// and check the scanner's error at the end. Failures come back as errors you can inspect.

package main

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"os"
)

// tasksPath finds the lesson's tasks.txt whether you run from go/ or from go/concepts/.
func tasksPath() string {
	for _, path := range []string{"tasks.txt", "concepts/tasks.txt"} {
		if _, err := os.Stat(path); err == nil {
			return path
		}
	}
	return "tasks.txt" // not found: loadTasks will say so
}

// readTasks reads tasks from any io.Reader: a file, or a string in a test. io.Reader is an
// interface with one method, Read, which is why both fit.
func readTasks(r io.Reader) ([]Task, error) {
	var lines []string
	scanner := bufio.NewScanner(r)
	for scanner.Scan() { // one line per step, without its newline
		lines = append(lines, scanner.Text())
	}
	if err := scanner.Err(); err != nil { // Scan returns false on an error too: ask which it was
		return nil, err
	}
	return parseTasks(lines)
}

// loadTasks opens path and reads its tasks. Lesson 14 uses it.
func loadTasks(path string) ([]Task, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, err // already says "open missing.txt: no such file or directory"
	}
	defer f.Close() // runs when loadTasks returns, on every path out of it
	tasks, err := readTasks(f)
	if err != nil {
		return nil, fmt.Errorf("load %s: %w", path, err)
	}
	return tasks, nil
}

func lesson13() {
	for _, path := range []string{tasksPath(), "missing.txt"} {
		tasks, err := loadTasks(path)
		if errors.Is(err, fs.ErrNotExist) { // the file isn't there: different from can't-read-it
			fmt.Println("missing.txt: not found -", err)
			continue
		}
		if err != nil {
			fmt.Println("error:", err)
			continue
		}
		done := 0
		for _, t := range tasks {
			if t.IsDone() {
				done++
			}
		}
		fmt.Printf("tasks.txt: %d tasks, %d done (%.0f%%); the first: %v\n", len(tasks), done, percent(done, len(tasks)), tasks[0])
	}

	scratch, err := os.CreateTemp("", "scratch-*.txt") // a fresh file nobody else is using
	if err != nil {
		fmt.Println("error:", err)
		return
	}
	defer os.Remove(scratch.Name()) // deferred calls run last-in, first-out: Remove after Close
	defer scratch.Close()
	fmt.Fprintln(scratch, "[todo] First") // Fprintln writes to any io.Writer, a file included
	out := bufio.NewWriter(scratch)       // buffered: collects small writes into one
	fmt.Fprintln(out, "[todo] Second")
	if err := out.Flush(); err != nil { // forget Flush and the last writes never reach the file
		fmt.Println("error:", err)
		return
	}
	data, err := os.ReadFile(scratch.Name()) // the whole file at once, for small files
	if err != nil {
		fmt.Println("error:", err)
		return
	}
	fmt.Printf("scratch file: %q\n", string(data))
}
