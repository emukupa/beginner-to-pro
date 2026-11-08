//go:build bug14

// Lesson 14's mistake: Largest needs >, and TagCount is a struct with no order. The constraint
// cmp.Ordered says so at build time; TopN, which takes a compare function, is the way to rank it.

package main

import "fmt"

func init() {
	bugs[14] = func() {
		fmt.Println(Largest([]TagCount{{"work", 3}, {"home", 2}}))
	}
}
