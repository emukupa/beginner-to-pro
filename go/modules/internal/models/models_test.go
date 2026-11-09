package models

import "testing"

// Every status except Other must have a spelling. range over an integer counts 0, 1, 2, ...
func TestEveryStatusIsSpelled(t *testing.T) {
	for s := range numStatuses {
		if s != Other && s.String() == "" {
			t.Errorf("status %d has no spelling: add it to Status.String", s)
		}
	}
}
