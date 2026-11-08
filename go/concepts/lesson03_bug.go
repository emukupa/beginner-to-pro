//go:build bug03

// Lesson 03's mistake: an int times a float64. Go won't guess which one you meant; write
// float64(count) * price yourself.

package main

import "fmt"

func init() {
	bugs[3] = func() {
		count, price := 3, 2.5
		fmt.Println(count * price)
	}
}
