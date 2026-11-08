//go:build bug07

// Lesson 07's mistake: i <= len instead of i < len, so the last step reads one past the end.

package main

import "fmt"

func init() {
	bugs[7] = func() {
		tasks := []string{"Buy groceries", "Call mom", "Book flights"}
		for i := 0; i <= len(tasks); i++ {
			fmt.Println(tasks[i])
		}
	}
}
