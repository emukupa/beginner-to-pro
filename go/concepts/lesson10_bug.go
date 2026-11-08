//go:build bug10

// Lesson 10's mistake: a *Task that was never pointed at anything. MarkDone tries to set
// t.Status through nil and the program panics.

package main

func init() {
	bugs[10] = func() {
		var t *Task
		t.MarkDone()
	}
}
