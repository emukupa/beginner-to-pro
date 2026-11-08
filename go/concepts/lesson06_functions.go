// Lesson 06: functions take copies of their arguments and can return several results. Functions
// are values too: you can store them, pass them, and build them on the spot as closures.
// -tags bug06: keeping one result of a function that returns two. Go makes you take both.

package main

import (
	"fmt"
	"strings"
)

// percent is done as a share of total, 0 when there's nothing to share. Lessons 13 and 14 use it.
func percent(done, total int) float64 { // done, total int: two parameters of the same type
	if total == 0 {
		return 0
	}
	return float64(done) / float64(total) * 100
}

// splitLine turns "[done.] Call mom #family" into "done", "Call mom", [family] and true.
// ok is false when the line isn't a task. Four results, named so the signature documents itself.
// Lesson 12's parseTask builds on it.
func splitLine(line string) (status, title string, tags []string, ok bool) {
	line = strings.TrimSpace(line) // line is our own copy: the caller's string is untouched
	if !strings.HasPrefix(line, "[") {
		return "", "", nil, false
	}
	rawStatus, rest, found := strings.Cut(line, "]")
	if !found {
		return "", "", nil, false
	}
	var words []string
	for _, word := range strings.Fields(rest) {
		if strings.HasPrefix(word, "#") {
			tags = append(tags, strings.ToLower(strings.Trim(strings.TrimLeft(word, "#"), ".,")))
		} else {
			words = append(words, word)
		}
	}
	return cleanStatus(rawStatus), strings.Join(words, " "), tags, true
}

// total takes any number of ints: inside, numbers is a slice.
func total(numbers ...int) int {
	sum := 0
	for _, n := range numbers {
		sum += n
	}
	return sum
}

// counter returns a closure: a function that keeps the variable count alive between calls.
func counter() func() int {
	count := 0
	return func() int {
		count++
		return count
	}
}

func lesson06() {
	fmt.Printf("percent(3, 6) = %.1f, percent(0, 0) = %.1f\n", percent(3, 6), percent(0, 0))
	status, title, tags, ok := splitLine("[done.] Call mom #family")
	fmt.Printf("splitLine -> %q %q %q %v\n", status, title, tags, ok)
	_, _, _, ok = splitLine("just a note") // _ throws away a result you don't need
	fmt.Println("a line without [ is a task?", ok)

	fmt.Println("total() =", total(), " total(1, 2, 3) =", total(1, 2, 3))
	counts := []int{2, 3, 1}
	fmt.Println("total(counts...) =", total(counts...)) // ... spreads a slice into the arguments

	next := counter()
	next()
	next()
	fmt.Println("the closure has counted to", next(), "- a fresh one starts at", counter()())

	shout := func(s string) string { return strings.ToUpper(s) + "!" } // a function literal, as a value
	apply := func(f func(string) string, s string) string { return f(s) }
	fmt.Println("passed a function:", apply(shout, "done"))
	bug(6)
}
