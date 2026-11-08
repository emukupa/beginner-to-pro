// Lesson 03: arithmetic, integer division, overflow, rounding, and turning text into a number.
// -tags bug03: multiplying an int by a float64. Go never converts number types for you.

package main

import (
	"fmt"
	"math"
	"strconv"
)

func lesson03() {
	fmt.Println("7 / 2 =", 7/2, " 7 % 2 =", 7%2, " 7.0 / 2 =", 7.0/2) // int / int drops the rest
	fmt.Println("-7 / 2 =", -7/2, " -7 % 2 =", -7%2)                  // towards zero: Python says -4 and 1
	a, b := 0.1, 0.2
	fmt.Println("a + b =", a+b, " but the constants 0.1 + 0.2 =", 0.1+0.2) // floats are binary: close, not exact
	// Constants are worked out exactly when the program is built; only float64 variables round.

	done, total := 3, 6
	fmt.Println("done*100/total =", done*100/total, " float64(done)/float64(total) =", float64(done)/float64(total))

	var small int8 = 127 // int8 holds -128..127
	small++
	fmt.Println("int8 127 + 1 =", small, "(Go defines the wrap; C calls it undefined)")

	// Halves: math.Round goes away from zero, math.RoundToEven goes to the even neighbour. Python's
	// round() halves to even, so the tracker uses RoundToEven to print the same percentages.
	for _, x := range []float64{0.5, 1.5, 2.5, 62.5} {
		fmt.Printf("%5.1f  Round %3.0f  RoundToEven %3.0f\n", x, math.Round(x), math.RoundToEven(x))
	}

	// Text from a file or the keyboard is a string; strconv.Atoi turns it into an int, or says why not.
	for _, answer := range []string{"5", "five", "-3"} {
		n, err := strconv.Atoi(answer) // two results: the number and an error (lesson 06, lesson 12)
		if err != nil {
			fmt.Printf("%q isn't a whole number\n", answer)
			continue
		}
		fmt.Printf("%q -> %d\n", answer, n)
	}
	bug(3)
}
