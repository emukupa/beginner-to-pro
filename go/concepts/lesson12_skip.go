//go:build !bug12

// parseTasks lives in its own file so that -tags bug12 can swap in lesson12_bug.go's broken one.

package main

import (
	"errors"
	"fmt"
)

// parseTasks parses every line, skips the ones that aren't tasks (blank lines, notes), and stops
// at any other problem, saying which line. Lesson 13's readTasks uses it.
func parseTasks(lines []string) ([]Task, error) {
	var tasks []Task
	for i, line := range lines {
		task, err := parseTask(line)
		if errors.Is(err, ErrNotTask) {
			continue
		}
		if err != nil {
			return nil, fmt.Errorf("line %d: %w", i+1, err)
		}
		tasks = append(tasks, task)
	}
	return tasks, nil
}
