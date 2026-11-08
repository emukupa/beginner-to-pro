//go:build bug11

// Lesson 11's mistake: using a Note as an Item. Note has String but no IsDone, so the compiler
// says exactly which method is missing.

package main

import "fmt"

func init() {
	bugs[11] = func() {
		var item Item = Note{"remember milk"}
		fmt.Println(item)
	}
}
