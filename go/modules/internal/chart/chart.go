// Package chart draws the bar chart, to any io.Writer.
package chart

import (
	"fmt"
	"io"
	"math"
	"strings"

	"github.com/emukupa/beginner-to-pro/go/modules/internal/tasklist"
)

// Width is the longest bar, in characters.
const Width = 20

const bar = "█"

// Draw writes the chart to w: the screen in main, a strings.Builder in a test. Any type with a
// Write method is an io.Writer; nothing has to declare it.
func Draw(w io.Writer, pairs []tasklist.TagCount, width int) {
	if len(pairs) == 0 {
		fmt.Fprintln(w, "No tags yet.")
		return
	}
	biggest := float64(pairs[0].Count)
	labelWidth := 0
	for _, p := range pairs {
		labelWidth = max(labelWidth, len([]rune(p.Tag)))
	}
	for _, p := range pairs {
		// RoundToEven is Python's round(); %-*s pads by runes, as Python pads by characters.
		blocks := int(math.RoundToEven(float64(p.Count) / biggest * float64(width)))
		fmt.Fprintf(w, "%-*s  %s %d\n", labelWidth, p.Tag, strings.Repeat(bar, blocks), p.Count)
	}
}
