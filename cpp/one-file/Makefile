# C++ build. Every build is strict; `make check` runs the contract under the sanitizers.
#   make            build/tracker: AddressSanitizer + UndefinedBehaviorSanitizer, for development
#   make run        build if needed, then run it here (make run ARGS=work.txt passes arguments)
#   make check      the contract against build/tracker
#   make leaks      one full run under macOS's leaks tool (ASan can't check leaks on macOS)
#   make release    build/tracker-release: optimised, no sanitizers
CXX     := clang++
CXXFLAGS := -std=c++23 -Wall -Wextra -Wpedantic -Wconversion -Wshadow -Werror -g
SAN     := -fsanitize=address,undefined -fno-sanitize-recover=all -fno-omit-frame-pointer
SOURCES := tracker.cpp

build/tracker: $(SOURCES) | build
	$(CXX) $(CXXFLAGS) $(SAN) -o $@ $(SOURCES)

build/tracker-plain: $(SOURCES) | build
	$(CXX) $(CXXFLAGS) -o $@ $(SOURCES)

build/tracker-release: $(SOURCES) | build
	$(CXX) $(CXXFLAGS) -O2 -o $@ $(SOURCES)

build:
	mkdir -p build

run: build/tracker
	./build/tracker $(ARGS)

check: build/tracker
	../../contract/run.sh "$(CURDIR)/build/tracker"

# Adds a task, then gives a bad number: the paths that allocate the most. Runs in build/leak-run.
leaks: build/tracker-plain
	mkdir -p build/leak-run
	cp ../../contract/tasks.txt build/leak-run/tasks.txt
	cd build/leak-run && printf 'Write video script #work #urgent\n\nfive\n' | \
		leaks --atExit --quiet -- ../tracker-plain > leaks.txt 2> /dev/null && echo "no leaks" || \
		{ cat leaks.txt; echo "LEAKS FOUND"; exit 1; }

release: build/tracker-release

clean:
	rm -rf build

.PHONY: run check leaks release clean
