# The task tracker in one Swift file.
#   make            swiftc -O tracker.swift into build/tracker (warnings are errors)
#   make run        run it on tasks.txt here
#   make check      the contract: must match Python byte for byte
build/tracker: tracker.swift
	@mkdir -p build
	swiftc -O -warnings-as-errors tracker.swift -o build/tracker

run: build/tracker
	./build/tracker

check: build/tracker
	../../contract/run.sh "$(CURDIR)/build/tracker"

.PHONY: run check
