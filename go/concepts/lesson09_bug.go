//go:build bug09

// Lesson 09's mistake: a Kind assigned to a Status. Named types keep the two apart, which is the
// whole point of giving them names.

package main

import "fmt"

func init() {
	bugs[9] = func() {
		var s Status = Urgent
		fmt.Println(s)
	}
}
