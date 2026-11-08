// Package parsing turns one line of text into a task. No files, no printing: text in, a Task out.
package parsing

import (
	"strings"

	"github.com/emukupa/beginner-to-pro/go/modules/internal/models"
)

// TagMarker marks a word as a tag: "#work".
const TagMarker = "#"

// statusOf is lowercase, so only this package can call it.
func statusOf(raw string) (models.Status, string) {
	word := strings.ToLower(strings.Trim(raw, "[] ."))
	switch word {
	case "done":
		return models.Done, word
	case "todo":
		return models.Todo, word
	}
	return models.Other, word
}

// Line turns "[done.] Call mom #family" into a Task. The second result says whether the line was a
// task at all: Go's comma-ok, where Python returned None. Callers write parsing.Line(...), so the
// package name is part of the name.
func Line(line string) (models.Task, bool) {
	s := strings.TrimSpace(line)
	if !strings.HasPrefix(s, "[") {
		return models.Task{}, false
	}
	raw, rest, _ := strings.Cut(s, "]") // Python's partition("]")
	status, word := statusOf(raw)
	var title, tags []string
	kind := models.Plain
	for _, w := range strings.Fields(rest) {
		if !strings.HasPrefix(w, TagMarker) {
			title = append(title, w)
			continue
		}
		tag := strings.ToLower(strings.Trim(strings.TrimLeft(w, TagMarker), ".,"))
		tags = append(tags, tag)
		if tag == "urgent" {
			kind = models.Urgent
		}
	}
	return models.Task{Title: strings.Join(title, " "), Tags: tags, Status: status, StatusWord: word, Kind: kind}, true
}
