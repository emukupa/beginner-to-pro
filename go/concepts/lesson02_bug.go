//go:build bug02

// Lesson 02's mistake: unused is declared and never read. Go treats that as an error, because an
// unused variable is usually a typo or a forgotten line.

package main

func init() {
	bugs[2] = func() {
		unused := 5
	}
}
