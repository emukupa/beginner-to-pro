// Go concepts, one lesson per file. Every file here is package main, so the whole folder builds as
// one program: a later lesson calls an earlier one's functions directly, with no imports. Real
// projects split code into packages; that's the modules chapter.
//
//	go run ./concepts              every lesson, in order (from go/)
//	go run ./concepts 7            just lesson 7          go run ./concepts 4 7   lessons 4 and 7
//	go run -tags bug07 ./concepts 7
//	                               lesson 7 with its deliberate mistake compiled in
//
// The mistakes live in lessonNN_bug.go files that start with //go:build bugNN. A build tag keeps a
// file out of every build unless you ask for it with -tags, so the normal program never sees them.
package main

import (
	"fmt"
	"os"
	"strconv"
)

type lesson struct {
	title string
	run   func() // a function is a value: each lesson's run function sits in the table
}

var lessons = []lesson{
	{"Hello", lesson01}, {"Values, types and zero values", lesson02}, {"Numbers", lesson03},
	{"Strings, bytes and runes", lesson04}, {"Decisions and loops", lesson05}, {"Functions", lesson06},
	{"Slices", lesson07}, {"Maps", lesson08}, {"Enums with iota", lesson09},
	{"Structs and methods", lesson10}, {"Embedding and interfaces", lesson11}, {"Errors", lesson12},
	{"Files", lesson13}, {"Generics and a stable sort", lesson14},
}

// bugs holds the deliberate mistakes. It starts empty; each lessonNN_bug.go adds its own from an
// init function, which Go runs before main. Package-level variables are ready before any init.
var bugs = map[int]func(){}

// bug runs lesson n's mistake, if this build has one compiled in. Without -tags it does nothing.
func bug(n int) {
	if mistake, ok := bugs[n]; ok {
		fmt.Printf("-- bug %02d compiled in --\n", n)
		mistake()
	}
}

func run(n int) {
	fmt.Printf("\n=== %02d %s ===\n", n, lessons[n-1].title)
	lessons[n-1].run()
}

func main() {
	if len(os.Args) == 1 {
		for n := range len(lessons) {
			run(n + 1)
		}
		return
	}
	for _, arg := range os.Args[1:] {
		n, err := strconv.Atoi(arg)
		if err != nil || n < 1 || n > len(lessons) {
			fmt.Fprintf(os.Stderr, "No lesson %s (there are %d)\n", arg, len(lessons))
			os.Exit(1)
		}
		run(n)
	}
}
