// Package storage is the tasks file: the only package that opens files.
package storage

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"strings"

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

// holds reports whether this line holds the task: the same title and status after parsing.
func holds(line string, task models.Task) bool {
	found, ok := parsing.Line(line)
	return ok && found.Title == task.Title && found.StatusWord == task.StatusWord
}

// SetStatus rewrites the line holding this task as [status], leaving every other byte of the file
// alone. It writes a new file beside the old one, then renames it over, so the tasks file is never
// half-written.
//
// err is a named result, so the deferred function below can read it: if SetStatus is returning an
// error, the half-made file is removed. That's Go's errdefer.
func SetStatus(path string, task models.Task, status models.Status) (err error) {
	word := status.String()
	if word == "" {
		return fmt.Errorf("status %d has no spelling", status) // before anything is opened
	}
	data, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	info, err := os.Stat(path)
	if err != nil {
		return err
	}

	var out strings.Builder
	changed := false
	for line := range strings.SplitAfterSeq(string(data), "\n") { // each line keeps its own ending
		open := strings.Index(line, "[")
		end := strings.Index(line[max(open, 0):], "]")
		if changed || open < 0 || end < 0 || !holds(line, task) {
			out.WriteString(line)
			continue
		}
		out.WriteString(line[:open]) // any spaces before the bracket
		out.WriteString("[" + word + "]")
		out.WriteString(line[open+end+1:]) // the title, tags and line ending
		changed = true
	}

	// A new file with a random name, beside the old one: rename needs the same disk.
	temp, err := os.CreateTemp(filepath.Dir(path), filepath.Base(path)+".*")
	if err != nil {
		return err
	}
	defer func() {
		if err != nil {
			temp.Close()
			os.Remove(temp.Name()) // never leave the half-made file behind
		}
	}()
	if err = temp.Chmod(info.Mode().Perm()); err != nil { // keep the old file's permissions
		return err
	}
	if _, err = temp.WriteString(out.String()); err != nil {
		return err
	}
	if err = temp.Sync(); err != nil { // on the disk before it replaces anything
		return err
	}
	if err = temp.Close(); err != nil {
		return err
	}
	return os.Rename(temp.Name(), path) // atomic: readers see the old file or the new one
}
