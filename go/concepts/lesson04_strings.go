// Lesson 04: a string is a read-only run of bytes, almost always UTF-8. len counts bytes, not
// letters; a rune is one Unicode character. Real data is messy, so we clean it.
// -tags bug04: changing one byte of a string. Strings never change, so it won't build.

package main

import (
	"fmt"
	"strings"
	"unicode/utf8"
)

// cleanStatus turns "[ DONE. ]" into "done". Lesson 06's splitLine uses it.
func cleanStatus(text string) string {
	return strings.ToLower(strings.Trim(text, "[] ."))
}

func lesson04() {
	fmt.Println(`"done" == "done." ->`, "done" == "done.", ` "done" == "DONE" ->`, "done" == "DONE")
	fmt.Printf("TrimSpace %q, ToLower %q\n", strings.TrimSpace("  done  "), strings.ToLower("DONE"))
	fmt.Printf("Fields %q\n", strings.Fields("Call  mom #family")) // splits on any run of spaces
	before, after, found := strings.Cut("[done.] Call mom", "]")   // like Python's partition
	fmt.Printf("Cut %q %q %v\n", before, after, found)
	for _, messy := range []string{"[done]", "[done.]", "[DONE]", "[ todo ]"} {
		fmt.Printf("%-10q -> %q\n", messy, cleanStatus(messy))
	}

	title := "Fix login bug"
	fmt.Printf("title[0] is the byte %d (%c); title[0:3] is %q\n", title[0], title[0], title[0:3])

	// Bytes and runes: é is 2 bytes, █ is 3. Charts must count runes, or they come out too short.
	for _, s := range []string{"done", "café", "███"} {
		fmt.Printf("%-6s len %d bytes, %d runes\n", s, len(s), utf8.RuneCountInString(s))
	}
	for i, r := range "café" { // range over a string steps one rune at a time; i is its byte offset
		fmt.Printf("%d:%c ", i, r)
	}
	fmt.Println()
	fmt.Printf("aligned: |%-8s|%8s|  repeated: %s\n", "work", "home", strings.Repeat("█", 5))

	var b strings.Builder // builds a long string without copying it on every step
	for _, word := range []string{"Buy", "groceries"} {
		if b.Len() > 0 {
			b.WriteString(" ")
		}
		b.WriteString(word)
	}
	fmt.Println("built:", b.String())
	bug(4)
}
