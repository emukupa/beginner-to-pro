//go:build bug06

// Lesson 06's mistake: strconv.Atoi returns a number and an error, and this keeps only one.
// Go won't let a result disappear silently: take both, or throw one away on purpose with _.

package main

import (
	"fmt"
	"strconv"
)

func init() {
	bugs[6] = func() {
		n := strconv.Atoi("4")
		fmt.Println(n)
	}
}
