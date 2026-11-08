// Lesson 01: a Go program is a package main with a func main; `go run` compiles it and runs it.
// -tags bug01: an import nothing uses. Go refuses to build: unused imports are errors, not warnings.

package main

import "fmt"

func lesson01() {
	fmt.Println("Hello from Go")                     // Println adds the spaces and the newline
	fmt.Printf("%s, %d and %.1f\n", "text", 42, 2.5) // Printf adds nothing: \n is yours to write
	fmt.Printf("%v works for anything: %v %v\n", 42, true, []string{"a", "b"})
	bug(1)
	// A program's exit code is 0 when main returns; os.Exit(1) ends it early with 1 (main.go does).
}
