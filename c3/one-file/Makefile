# C3 build. The development build is -O0, C3's safe mode: bounds, null and contract checks on.
#   make            build/tracker, safe mode, for development
#   make run        build if needed, then run it here (make run ARGS=work.txt passes arguments)
#   make check      the contract against build/tracker
#   make leaks      one full run under macOS's leaks tool
#   make release    build/tracker-release: optimised, the safety checks compiled out
C3C     ?= c3c
SOURCES := tracker.c3

build/tracker: $(SOURCES) | build
	$(C3C) compile -q -O0 -o $@ $(SOURCES)

build/tracker-release: $(SOURCES) | build
	$(C3C) compile -q -O3 -o $@ $(SOURCES)

build:
	mkdir -p build

run: build/tracker
	./build/tracker $(ARGS)

check: build/tracker
	../../contract/run.sh "$(CURDIR)/build/tracker"

# Adds a task, then gives a bad number: the paths that allocate the most. Runs in build/leak-run.
leaks: build/tracker
	mkdir -p build/leak-run
	cp ../../contract/tasks.txt build/leak-run/tasks.txt
	cd build/leak-run && printf 'Write video script #work #urgent\n\nfive\n' | \
		leaks --atExit --quiet -- ../tracker > leaks.txt 2> /dev/null && echo "no leaks" || \
		{ cat leaks.txt; echo "LEAKS FOUND"; exit 1; }

release: build/tracker-release

clean:
	rm -rf build

.PHONY: run check leaks release clean
