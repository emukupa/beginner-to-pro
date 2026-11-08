package parsing

import (
	"slices"
	"testing"

	"github.com/emukupa/beginner-to-pro/go/modules/internal/models"
)

// A table-driven test: one row per case, one loop to check them all. Being in package parsing, it
// can call the unexported statusOf too.
func TestLine(t *testing.T) {
	tests := []struct {
		line   string
		ok     bool
		title  string
		status models.Status
		tags   []string
	}{
		{"[DONE.] Call mom #Family #urgent,", true, "Call mom", models.Done, []string{"family", "urgent"}},
		{"  [ todo ] Review pull request #work.", true, "Review pull request", models.Todo, []string{"work"}},
		{"[later] Water plants", true, "Water plants", models.Other, nil},
		{"Buy milk #home", false, "", models.Todo, nil},
	}
	for _, tt := range tests {
		task, ok := Line(tt.line)
		if ok != tt.ok || task.Title != tt.title || task.Status != tt.status || !slices.Equal(task.Tags, tt.tags) {
			t.Errorf("Line(%q) = %+v, %v", tt.line, task, ok)
		}
	}
}

func TestStatusOf(t *testing.T) {
	if status, word := statusOf("[later"); status != models.Other || word != "later" {
		t.Errorf("statusOf kept %v %q", status, word)
	}
}
