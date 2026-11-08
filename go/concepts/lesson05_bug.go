//go:build bug05

// Lesson 05's mistake: %d wants a number but gets a string. The compiler can't see inside the
// format string, so this builds; it prints %!d(string=six) at run time, and go vet reports it.

package main

import "fmt"

func init() {
	bugs[5] = func() {
		fmt.Printf("%d tasks\n", "six")
	}
}
