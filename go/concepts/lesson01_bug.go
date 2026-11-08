//go:build bug01

// Lesson 01's mistake: os is imported and never used. The build stops before anything runs.

package main

import "os"
