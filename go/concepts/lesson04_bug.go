//go:build bug04

// Lesson 04's mistake: assigning to one byte of a string. Strings are read-only; make a new one
// (or convert to []byte, change that, and convert back).

package main

func init() {
	bugs[4] = func() {
		status := "done"
		status[0] = 'D'
	}
}
