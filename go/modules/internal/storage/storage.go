// Package storage is the tasks file: the only package that opens files.
package storage

import (
	"bufio"
	"fmt"
	"os"

	"github.com/emukupa/beginner-to-pro/go/modules/internal/models"
	"github.com/emukupa/beginner-to-pro/go/modules/internal/parsing"
)

// Load returns every task in the file; lines that aren't tasks are skipped. Errors are wrapped with
// %w, so the caller can still ask errors.Is(err, fs.ErrNotExist).
func Load(path string) ([]models.Task, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, fmt.Errorf("load tasks: %w", err)
	}
	defer f.Close() // however this function returns
	var tasks []models.Task
	lines := bufio.NewScanner(f) // one line at a time, "\r\n" endings handled
	lines.Buffer(make([]byte, 64*1024), 16*1024*1024)
	for lines.Scan() {
		if task, ok := parsing.Line(lines.Text()); ok {
			tasks = append(tasks, task)
		}
	}
	if err := lines.Err(); err != nil {
		return nil, fmt.Errorf("load tasks: %w", err)
	}
	return tasks, nil
}

// AppendTitles writes "[todo] title" lines on the end of the file.
func AppendTitles(path string, titles []string) error {
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
