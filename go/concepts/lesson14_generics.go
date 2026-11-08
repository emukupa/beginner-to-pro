// Lesson 14: generics let one function work on many types, with a type parameter in [brackets].
// TopN ranks anything you can compare, with a stable sort so ties keep the order they came in.
// Then everything so far adds up to a small tracker: load, parse, count, rank, chart.
// -tags bug14: calling Largest with a type that can't be compared with <. It won't build.

package main

import (
	"cmp"
	"fmt"
	"math"
	"slices"
	"strings"
)

// TagCount pairs a tag with how many tasks carry it.
type TagCount struct {
	Tag   string
	Count int
}

// TopN returns the first n items once sorted by compare (negative: a before b). T can be any type;
// compare says how to order it. SortStableFunc never swaps equal items, which the ties need.
// We sort a clone, so the caller's slice keeps its order.
func TopN[T any](items []T, n int, compare func(a, b T) int) []T {
	sorted := slices.Clone(items)
	slices.SortStableFunc(sorted, compare)
	return sorted[:min(n, len(sorted))]
}

// Largest needs < itself, so its T is constrained: cmp.Ordered means numbers and strings only.
func Largest[T cmp.Ordered](items []T) T {
	best := items[0]
	for _, item := range items[1:] {
		if item > best {
			best = item
		}
	}
	return best
}

// mostFirst orders tag counts from most to fewest. cmp.Compare gives -1, 0 or 1.
func mostFirst(a, b TagCount) int { return cmp.Compare(b.Count, a.Count) }

func lesson14() {
	fmt.Println("Largest ints:", Largest([]int{3, 9, 4}), " Largest strings:", Largest([]string{"home", "work"}))
	fmt.Println("TopN 2 numbers:", TopN([]int{5, 1, 4}, 2, cmp.Compare[int])) // T is worked out from the slice

	tasks, err := loadTasks(tasksPath()) // lesson 13
	if err != nil {
		fmt.Println("error:", err)
		return
	}
	done := 0
	var tagLists [][]string
	var shown []fmt.Stringer // lesson 11: tasks and urgent tasks side by side
	for _, t := range tasks {
		if t.IsDone() {
			done++
		}
		tagLists = append(tagLists, t.Tags)
		if t.HasTag("urgent") {
			shown = append(shown, UrgentTask{Task: t, Due: "soon"})
		} else {
			shown = append(shown, t)
		}
	}
	for _, s := range shown {
		fmt.Println(" ", s)
	}
	fmt.Printf("%d of %d done (%.0f%%)\n", done, len(tasks), math.RoundToEven(percent(done, len(tasks))))

	order, counts := countTags(tagLists) // lesson 08: first-seen order, because the map has none
	tagCounts := make([]TagCount, 0, len(order))
	for _, tag := range order {
		tagCounts = append(tagCounts, TagCount{tag, counts[tag]})
	}
	for _, tc := range TopN(tagCounts, len(tagCounts), mostFirst) {
		fmt.Printf("%-7s %s %d\n", tc.Tag, strings.Repeat("█", tc.Count*4), tc.Count)
	}
	top := TopN(tagCounts, 3, mostFirst)
	fmt.Printf("top 3: %v (urgent beats family and travel: seen first)\n", top)
	bug(14)
}
