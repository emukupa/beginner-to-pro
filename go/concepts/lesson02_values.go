// Lesson 02: every value has a type, fixed when the program is built. A variable you don't set
// starts at its type's zero value, so there's no such thing as an uninitialised variable in Go.
// -tags bug02: a variable that's declared and never used. Like an unused import, it won't build.

package main

import "fmt"

func lesson02() {
	var title string = "Buy groceries" // the long way: var, name, type, value
	done := true                       // := declares and infers the type: the short way, inside functions
	count := 6
	ratio := 0.5
	fmt.Printf("%q is a %T, %v a %T, %v an %T, %v a %T\n", title, title, done, done, count, count, ratio, ratio)

	var zeroText string // nothing assigned: each starts at its zero value
	var zeroCount int
	var zeroDone bool
	var zeroTags []string // nil: a slice with nothing behind it yet (lesson 07)
	fmt.Printf("zero values: %q %d %v %v (nil? %v)\n", zeroText, zeroCount, zeroDone, zeroTags, zeroTags == nil)

	const marker = "#" // a constant: fixed when the program is built, can never change
	const width = 4    // untyped: it takes whatever number type it's used as
	fmt.Println("marker", marker, "width as a float:", width*0.5)

	count, ratio = 7, 0.25 // assignment uses =; := is only for new names
	fmt.Println("after reassigning:", count, ratio)
	bug(2)
}
