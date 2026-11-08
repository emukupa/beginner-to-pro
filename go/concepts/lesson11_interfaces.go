// Lesson 11: Go has no classes and no inheritance. Embedding puts one struct inside another and
// lends it the inner one's fields and methods. An interface is a set of methods; any type that
// has them satisfies it, with no "implements" anywhere. That's how fmt finds String().
// -tags bug11: a type that's missing one of an interface's methods. It won't build.

package main

import "fmt"

// UrgentTask is a Task with a deadline. Embedding Task (a field with no name) gives it Title,
// Status, IsDone, MarkDone and the rest. Go's answer to inheritance.
type UrgentTask struct {
	Task
	Due string
}

// String replaces the embedded Task's String for UrgentTask: u.String() finds this one first.
func (u UrgentTask) String() string {
	return "!! " + u.Task.String() + " (due " + u.Due + ")" // the inner one is still there, by name
}

// Describe belongs to Task. Called on an UrgentTask, it still calls Task's String: an embedded
// type doesn't know what it's inside. Embedding is composition, not inheritance.
func (t Task) Describe() string { return "task " + t.String() }

// Item is our own interface: anything that prints and knows whether it's done.
type Item interface {
	fmt.Stringer // embedding an interface adds its methods: String() string
	IsDone() bool
}

// Note isn't a task: it prints, but it can't be done.
type Note struct{ Text string }

func (n Note) String() string { return "note: " + n.Text }

// These lines check at build time that the types still satisfy the interfaces; they cost nothing.
var (
	_ Item         = Task{}
	_ Item         = UrgentTask{}
	_ fmt.Stringer = Note{}
)

func lesson11() {
	u := UrgentTask{Task: Task{Title: "Finish quarterly report", Tags: []string{"work", "urgent"}}, Due: "Friday"}
	u.MarkDone() // promoted from Task: really u.Task.MarkDone()
	fmt.Println("promoted field and method:", u.Title, u.IsDone())
	fmt.Println(u)
	fmt.Println(u.Describe(), "<- Task's String, not UrgentTask's")

	items := []Item{Task{Title: "Buy groceries"}, u} // one slice, two types: both satisfy Item
	for _, item := range items {
		fmt.Printf("done=%-5v %v\n", item.IsDone(), item)
	}

	things := []fmt.Stringer{Task{Title: "Call mom"}, u, Note{"remember milk"}}
	for _, thing := range things {
		switch v := thing.(type) { // a type switch: which concrete type is inside the interface?
		case UrgentTask:
			fmt.Println("urgent, due", v.Due)
		case Task:
			fmt.Println("plain task:", v.Title)
		default:
			fmt.Println("something else:", v)
		}
	}
	if item, ok := things[2].(Item); ok { // a type assertion, with comma ok so it can't panic
		fmt.Println("a Note is an Item?", item)
	} else {
		fmt.Println("a Note is an Item? no: it has no IsDone")
	}
	bug(11)
}
