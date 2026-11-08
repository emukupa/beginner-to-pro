// Lesson 10: a struct bundles named fields into one value. Methods with a value receiver get a copy;
// methods with a pointer receiver can change the original.
// -tags bug10: calling a method through a nil pointer. It panics the moment it reaches a field.

package main

import (
	"fmt"
	"slices"
	"strings"
)

// Task is one line of the tasks file, parsed. Lessons 11 to 14 build on it.
type Task struct {
	Title  string
	Status Status   // lesson 09's enum
	Tags   []string // capitals: exported, visible outside the package (the modules chapter)
}

// IsDone only reads, so a value receiver is enough: t is a copy of the task.
func (t Task) IsDone() bool { return t.Status == Done }

// HasTag reports whether the task carries a tag, such as "urgent".
func (t Task) HasTag(tag string) bool { return slices.Contains(t.Tags, tag) }

// MarkDone changes the task, so it needs a pointer receiver: t points at the caller's Task.
func (t *Task) MarkDone() { t.Status = Done }

// markDoneOnCopy has a value receiver, so it changes a copy that's thrown away. A real bug, shown on purpose.
func (t Task) markDoneOnCopy() { t.Status = Done }

// String is how a Task prints: "[done] Call mom #family".
func (t Task) String() string {
	var b strings.Builder
	fmt.Fprintf(&b, "[%v] %s", t.Status, t.Title)
	for _, tag := range t.Tags {
		b.WriteString(" #" + tag)
	}
	return b.String()
}

func lesson10() {
	t := Task{Title: "Call mom", Tags: []string{"family"}} // fields by name; Status left at Todo
	fmt.Println(t, "| done?", t.IsDone(), "| #family?", t.HasTag("family"))
	t.markDoneOnCopy()
	fmt.Println("after markDoneOnCopy:", t.Status, "(the copy was changed, not t)")
	t.MarkDone() // Go takes &t for you, because MarkDone wants a pointer
	fmt.Println("after MarkDone:      ", t.Status)

	p := &t // a pointer to t
	p.Title = "Call dad"
	fmt.Println("through a pointer, p.Title changes t:", t.Title)

	copied := t // assigning a struct copies its fields...
	copied.Title = "Copy"
	copied.Tags[0] = "shared" // ...but a slice field still points at the same array
	fmt.Printf("t is %q #%s after changing the copy\n", t.Title, t.Tags[0])

	var empty Task // every field at its zero value
	fmt.Printf("zero Task: %q %v %v\n", empty.Title, empty.Status, empty.Tags == nil)
	point := struct{ X, Y int }{1, 2} // an anonymous struct, for a one-off
	fmt.Println("anonymous struct:", point, point == struct{ X, Y int }{1, 2})
	bug(10)
}
