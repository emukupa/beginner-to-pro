// Lesson 07: a slice is a window onto an array: a pointer, a length and a capacity. append grows
// it, copying into a bigger array when the capacity runs out. Two slices can share one array.
// -tags bug07: a loop that runs one step too far. Go checks every index and panics instead of
// reading whatever memory comes next (which is what C does).

package main

import (
	"fmt"
	"slices"
)

func lesson07() {
	tasks := []string{"Buy groceries", "Call mom"} // a slice literal
	tasks = append(tasks, "Book flights")          // append returns the slice: always keep the result
	fmt.Printf("%q len %d\n", tasks, len(tasks))
	fmt.Printf("tasks[1:] %q  tasks[:1] %q  last %q\n", tasks[1:], tasks[:1], tasks[len(tasks)-1])

	room := make([]string, 0, 2) // length 0, room for 2 before append has to move house
	fmt.Println("make: len", len(room), "cap", cap(room))
	room = append(room, "a", "b", "c")
	fmt.Println("after 3 appends: len", len(room), "cap grew past 2?", cap(room) > 2)

	a := []int{1, 2, 3}
	b := a[:2] // not a copy: b looks at the first two of a's numbers
	b[0] = 99
	fmt.Println("b[0] = 99 changed a too:", a)
	b = append(b, 7) // b still had room (a's third slot), so append wrote there
	fmt.Println("append to b overwrote a[2]:", a)
	c := slices.Clone(a) // a real copy, with its own array
	c[0] = 1
	fmt.Println("a clone is separate:", a, c)

	fmt.Println("Contains Call mom?", slices.Contains(tasks, "Call mom"), " Index of Book flights:", slices.Index(tasks, "Book flights"))
	var none []string // nil, yet len, range and append all work on it
	none = append(none, "first")
	fmt.Printf("append to a nil slice: %q\n", none)
	bug(7)
}
