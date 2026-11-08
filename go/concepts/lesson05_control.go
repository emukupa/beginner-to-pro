// Lesson 05: if, for (Go's only loop, in three shapes) and switch. A switch case stops on its own;
// there's no falling through into the next case unless you write fallthrough.
// -tags bug05: a Printf verb that doesn't match its value. It builds and runs; go vet catches it.

package main

import "fmt"

func lesson05() {
	done, total := 3, 6
	if done == total {
		fmt.Println("all done")
	} else if done == 0 {
		fmt.Println("nothing done")
	} else {
		fmt.Println(done, "of", total, "done")
	}
	if left := total - done; left > 0 { // a short statement before the condition: left only lives here
		fmt.Println(left, "left")
	}

	for i := 0; i < 3; i++ { // the C shape
		fmt.Print(i, " ")
	}
	for i := range 3 { // range over a number: 0, 1, 2
		fmt.Print(i*10, " ")
	}
	n := 1
	for n < 100 { // the while shape
		n *= 3
	}
	fmt.Println("| first power of 3 past 100:", n)

	for i, status := range []string{"done", "todo", "", "done", "?"} {
		if status == "" {
			continue // skip to the next one
		}
		if status == "?" {
			break // leave the loop
		}
		switch status {
		case "done":
			fmt.Printf("%d: finished\n", i)
		case "todo", "doing": // one case, several values
			fmt.Printf("%d: still to do\n", i)
		default:
			fmt.Printf("%d: unknown\n", i)
		}
	}

	switch { // no value: each case is a condition, the first true one runs
	case done*2 > total:
		fmt.Println("more than half")
	case done*2 == total:
		fmt.Println("exactly half")
	default:
		fmt.Println("less than half")
	}
	bug(5)
}
