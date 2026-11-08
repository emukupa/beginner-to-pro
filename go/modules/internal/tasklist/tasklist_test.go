package tasklist

import (
	"errors"
	"testing"

	"github.com/emukupa/beginner-to-pro/go/modules/internal/models"
	"github.com/emukupa/beginner-to-pro/go/modules/internal/parsing"
)

func load(lines ...string) []models.Task {
	var tasks []models.Task
	for _, l := range lines {
		if t, ok := parsing.Line(l); ok {
			tasks = append(tasks, t)
		}
	}
	return tasks
}

func TestTopTagsKeepsFirstSeenOrderForTies(t *testing.T) {
	tasks := load("[todo] a #work #home", "[todo] b #home #work", "[todo] c #play")
	got, err := TopTags(tasks, 3, true)
	if err != nil || len(got) != 3 || got[0].Tag != "work" || got[1].Tag != "home" || got[2].Tag != "play" {
		t.Errorf("TopTags = %v, %v", got, err)
	}
}

func TestTopTagsRefusesZero(t *testing.T) {
	if _, err := TopTags(nil, 0, true); !errors.Is(err, ErrNeedAtLeastOne) {
		t.Errorf("TopTags(0) error = %v", err)
	}
}

func TestTopNWorksForAnyType(t *testing.T) {
	got := TopN([]string{"aa", "b", "ccc"}, 2, func(s string) int { return len(s) })
	if len(got) != 2 || got[0] != "ccc" || got[1] != "aa" {
		t.Errorf("TopN = %v", got)
	}
}
