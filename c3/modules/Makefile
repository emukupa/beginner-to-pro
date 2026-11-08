# C3 build. One module per file in tracker/; c3c compiles them together, so there are no headers
# and nothing to link by hand. The development build is -O0, C3's safe mode.
#   make            build/tracker, safe mode, for development
#   make run        build if needed, then run it here (make run ARGS=work.txt passes arguments)
#   make check      the contract against build/tracker: the 8 cases, then the 6 done cases
#   make leaks      a full run and a done run under macOS's leaks tool
#   make release    build/tracker-release: optimised, the safety checks compiled out
C3C     ?= c3c
SOURCES := $(wildcard tracker/*.c3)

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
	CASES=done ../../contract/run.sh "$(CURDIR)/build/tracker"

# Adds a task, then gives a bad number: the paths that allocate the most. Runs in build/leak-run.
leaks: build/tracker
	mkdir -p build/leak-run
	cp ../../contract/tasks.txt build/leak-run/tasks.txt
	cd build/leak-run && printf 'Write video script #work #urgent\n\nfive\n' | \
		leaks --atExit --quiet -- ../tracker > leaks.txt 2> /dev/null && echo "no leaks" || \
		{ cat leaks.txt; echo "LEAKS FOUND"; exit 1; }
	cd build/leak-run && leaks --atExit --quiet -- ../tracker done "  book FLIGHTS " > leaks.txt 2> /dev/null && \
		echo "no leaks" || { cat leaks.txt; echo "LEAKS FOUND"; exit 1; }

release: build/tracker-release

clean:
	rm -rf build

.PHONY: run check leaks release clean
