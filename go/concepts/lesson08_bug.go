//go:build bug08

// Lesson 08's mistake: var declares the map but doesn't make it, so it's nil. Writing to it panics;
// counts := make(map[string]int) is the fix.

package main

import "fmt"

func init() {
	bugs[8] = func() {
		var counts map[string]int
		fmt.Println("reading a nil map is fine:", counts["work"])
		counts["work"]++
	}
}
