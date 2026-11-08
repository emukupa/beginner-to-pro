// Lesson 08: a map looks up a value by its key. A missing key gives the zero value, so counting
// needs no setup. Maps have no order: Go even shuffles it on purpose, so nobody relies on one.
// -tags bug08: writing to a nil map. Reading one is fine; writing panics.

package main

import (
	"fmt"
	"maps"
	"slices"
)

// countTags counts every tag, and remembers the order each was first seen in, because the map
// can't. The ranking keeps tied tags in that order, so the output is the same on every run.
// Lessons 13 and 14 use it.
func countTags(tagLists [][]string) (order []string, counts map[string]int) {
	counts = make(map[string]int) // make: an empty map, ready to write to
	for _, tags := range tagLists {
		for _, tag := range tags {
			if counts[tag] == 0 {
				order = append(order, tag)
			}
			counts[tag]++ // a missing key reads as 0, so the first ++ makes it 1
		}
	}
	return order, counts
}

func lesson08() {
	counts := map[string]int{"work": 3, "home": 2} // a map literal
	counts["family"] = 1
	fmt.Println("work:", counts["work"], " travel (missing):", counts["travel"], " len:", len(counts))
	n, found := counts["travel"] // comma ok: was it really there, or just the zero value?
	fmt.Println("travel:", n, found)
	delete(counts, "family")

	// Printing a map sorts its keys for you, but range doesn't: sort the keys when order matters.
	fmt.Println("printed:", counts, " sorted keys:", slices.Sorted(maps.Keys(counts)))

	seen := map[string]bool{} // a set: the keys are what matter
	for _, tag := range []string{"work", "home", "work"} {
		seen[tag] = true
	}
	fmt.Println("distinct tags:", len(seen))

	tagLists := [][]string{{"home"}, {"work", "urgent"}, {"family"}, {"work"}, {"travel", "home"}, {"work"}}
	order, tagCounts := countTags(tagLists)
	for _, tag := range order { // the order slice, not the map, decides what comes first
		fmt.Printf("%s=%d ", tag, tagCounts[tag])
	}
	fmt.Println("(first-seen order)")
	bug(8)
}
