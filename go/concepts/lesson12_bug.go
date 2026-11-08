//go:build bug12

// Lesson 12's mistake: the error is thrown away with _, so blank lines and notes become empty
// tasks and "[todo]" sails through. Nothing stops this building; TestParseTasks catches it.

package main

func parseTasks(lines []string) ([]Task, error) {
	var tasks []Task
	for _, line := range lines {
		task, _ := parseTask(line)
		tasks = append(tasks, task)
	}
	return tasks, nil
}
