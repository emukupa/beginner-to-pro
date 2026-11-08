// Lesson 09: Go has no enum keyword. A named type plus a block of constants numbered by iota does
// the job, and a String method gives each one a name when printed. This is also our first method.
// -tags bug09: putting a Kind where a Status belongs. They're both ints underneath, but different
// named types, so it won't build.

package main

import "fmt"

// Status is a task's cleaned status. Its own type, so it can't be mixed up with any other int.
type Status int

const (
	Todo  Status = iota // iota counts up from 0 in a const block: Todo 0, Done 1, Other 2
	Done                // repeats the line above: Status = iota, now 1
	Other               // anything we don't recognise, like [doing]
)

// String is a method: a function attached to Status. fmt calls it whenever it prints a Status
// (lesson 11 shows how fmt knows to).
func (s Status) String() string {
	switch s {
	case Todo:
		return "todo"
	case Done:
		return "done"
	case Other:
		return "other"
	}
	return fmt.Sprintf("Status(%d)", int(s)) // any other number: still printable, clearly wrong
}

// parseStatus turns a cleaned status ("done", from cleanStatus) into a Status. Lesson 12 uses it.
func parseStatus(cleaned string) Status {
	switch cleaned {
	case "done":
		return Done
	case "todo":
		return Todo
	}
	return Other
}

// Kind says what sort of task it is: urgent ones are tagged #urgent.
type Kind int

const (
	Plain Kind = iota
	Urgent
)

func lesson09() {
	fmt.Println("Todo, Done, Other are", int(Todo), int(Done), int(Other), "underneath")
	fmt.Println("printed, they use String():", Todo, Done, Other)
	fmt.Printf("%%v %v, %%d %d, %%T %T\n", Done, Done, Done)
	for _, text := range []string{"done", "todo", "doing"} {
		fmt.Printf("parseStatus(%q) -> %v\n", text, parseStatus(text))
	}
	fmt.Println("a number with no name:", Status(7))
	var s Status // the zero value is the first constant: one reason Todo comes first
	fmt.Println("zero Status:", s, " Urgent is Kind", int(Urgent))
	bug(9)
}
