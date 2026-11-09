// Package models says what a task is. Every other package uses it; it uses none of ours.
//
// A name that starts with a capital letter is exported: other packages can use it. Lowercase names
// stay inside the package. That's Go's only visibility rule.
package models

// Status is a small named type, and iota numbers its values.
type Status int

const (
	Todo Status = iota
	Done
	Other       // a status we didn't recognise; Task.StatusWord keeps the word
	numStatuses // not a status: how many there are, so a test can check every one
)

// String spells a status between the brackets. Go's switch doesn't check that every value is
// handled, so models_test.go does: add a status without a spelling, and the test fails.
func (s Status) String() string {
	switch s {
	case Todo:
		return "todo"
	case Done:
		return "done"
	}
	return "" // Other has no single spelling: each task keeps its own in StatusWord
}

// Kind replaces Python's UrgentTask subclass: Go has no inheritance.
type Kind int

const (
	Plain Kind = iota
	Urgent
)

type Task struct {
	Title      string
	Tags       []string
	Status     Status
	StatusWord string // the cleaned word between the brackets, for any status
	Kind       Kind
}

func (t Task) IsDone() bool { return t.Status == Done }

// String makes Task a fmt.Stringer: "[ ] Title", and "  !!" on the end of an urgent one.
func (t Task) String() string {
	mark, urgent := " ", ""
	if t.IsDone() {
		mark = "x"
	}
	if t.Kind == Urgent {
		urgent = "  !!"
	}
	return "[" + mark + "] " + t.Title + urgent
}
