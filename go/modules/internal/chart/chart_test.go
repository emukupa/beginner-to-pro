package chart

import (
	"strings"
	"testing"

	"github.com/emukupa/beginner-to-pro/go/modules/internal/tasklist"
)

func TestDrawIntoMemory(t *testing.T) {
	var out strings.Builder
	Draw(&out, []tasklist.TagCount{{Tag: "home", Count: 2}, {Tag: "work", Count: 1}}, 4)
	if want := "home  ████ 2\nwork  ██ 1\n"; out.String() != want {
		t.Errorf("Draw wrote %q, want %q", out.String(), want)
	}
}
