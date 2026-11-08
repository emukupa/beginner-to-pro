// Package tasklist works with the list: adding, counting, ranking, summing up. No files, no printing.
package tasklist

import (
	"cmp"
	"errors"
	"slices"

	"github.com/emukupa/beginner-to-pro/go/modules/internal/models"
	"github.com/emukupa/beginner-to-pro/go/modules/internal/parsing"
)

// Add parses each title as a new "[todo]" task and adds it. It returns the longer slice and how many
// were added: append may move the slice, so the caller must use the one it gets back.
func Add(tasks []models.Task, titles []string) ([]models.Task, int) {
	added := 0
	for _, title := range titles {
		if task, ok := parsing.Line("[todo] " + title); ok {
			tasks = append(tasks, task)
			added++
		}
	}
	return tasks, added
}

type TagCount struct {
	Tag   string
	Count int
}

// CountTags counts every tag, in the order each first appears. A map finds a tag's place fast, but
// ranging over a map gives a different order every run, so the slice keeps the order.
func CountTags(tasks []models.Task, includeDone bool) []TagCount {
	var counts []TagCount
	place := map[string]int{}
	for _, task := range tasks {
		if !includeDone && task.IsDone() {
			continue
		}
		for _, tag := range task.Tags {
			i, seen := place[tag]
			if !seen {
				i = len(counts)
				place[tag] = i
				counts = append(counts, TagCount{Tag: tag})
			}
			counts[i].Count++
		}
	}
	return counts
}

// TopN is generic: the n items with the biggest key, biggest first, for any type T. SortStableFunc
// is stable, so items with the same key keep their order.
func TopN[T any](items []T, n int, key func(T) int) []T {
	sorted := slices.Clone(items)
	slices.SortStableFunc(sorted, func(a, b T) int { return cmp.Compare(key(b), key(a)) })
	return sorted[:min(n, len(sorted))]
}

// ErrNeedAtLeastOne is a sentinel error: one value, compared with errors.Is. Python's ValueError.
var ErrNeedAtLeastOne = errors.New("need at least 1 top tag")

func TopTags(tasks []models.Task, n int, includeDone bool) ([]TagCount, error) {
	if n < 1 {
		return nil, ErrNeedAtLeastOne
	}
	return TopN(CountTags(tasks, includeDone), n, func(c TagCount) int { return c.Count }), nil
}

// Summary is the numbers on the summary line.
type Summary struct {
	Total, Done, Tags int
	Percent           float64
}

func Summarize(tasks []models.Task) Summary {
	s := Summary{Total: len(tasks), Tags: len(CountTags(tasks, true))}
	for _, t := range tasks {
		if t.IsDone() {
			s.Done++
		}
	}
	if s.Total > 0 {
		s.Percent = float64(s.Done) / float64(s.Total) * 100
	}
	return s
}
