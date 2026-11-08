# C++ build. Every build is strict; `make check` runs the contract under the sanitizers.
#   make            build/tracker: AddressSanitizer + UndefinedBehaviorSanitizer, for development
#   make run        build if needed, then run it here (make run ARGS=work.txt passes arguments)
#   make check      the contract against build/tracker: the 8 cases, then the 6 done cases
#   make leaks      a full run and a done run under macOS's leaks tool (ASan can't check leaks on macOS)
#   make release    build/tracker-release: optimised, no sanitizers
# Each module compiles to its own object file, so changing one .cpp rebuilds only that file, and
# -MMD records which headers each one includes, so changing a .hpp rebuilds exactly the files using it.
CXX     := clang++
CXXFLAGS := -std=c++23 -Wall -Wextra -Wpedantic -Wconversion -Wshadow -Werror -g -MMD -MP
SAN     := -fsanitize=address,undefined -fno-sanitize-recover=all -fno-omit-frame-pointer
SOURCES := $(wildcard tracker/*.cpp)

build/tracker: $(SOURCES:tracker/%.cpp=build/san/%.o)
	$(CXX) $(SAN) -o $@ $^

build/tracker-plain: $(SOURCES:tracker/%.cpp=build/plain/%.o)
	$(CXX) -o $@ $^

build/tracker-release: $(SOURCES:tracker/%.cpp=build/release/%.o)
	$(CXX) -o $@ $^

build/san/%.o: tracker/%.cpp | build/san
	$(CXX) $(CXXFLAGS) $(SAN) -c -o $@ $<

build/plain/%.o: tracker/%.cpp | build/plain
	$(CXX) $(CXXFLAGS) -c -o $@ $<

build/release/%.o: tracker/%.cpp | build/release
	$(CXX) $(CXXFLAGS) -O2 -c -o $@ $<

build/san build/plain build/release:
	mkdir -p $@

run: build/tracker
	./build/tracker $(ARGS)

check: build/tracker
	../../contract/run.sh "$(CURDIR)/build/tracker"
	CASES=done ../../contract/run.sh "$(CURDIR)/build/tracker"

# Adds a task, then gives a bad number: the paths that allocate the most. Runs in build/leak-run.
leaks: build/tracker-plain
	mkdir -p build/leak-run
	cp ../../contract/tasks.txt build/leak-run/tasks.txt
	cd build/leak-run && printf 'Write video script #work #urgent\n\nfive\n' | \
		leaks --atExit --quiet -- ../tracker-plain > leaks.txt 2> /dev/null && echo "no leaks" || \
		{ cat leaks.txt; echo "LEAKS FOUND"; exit 1; }
	cd build/leak-run && leaks --atExit --quiet -- ../tracker-plain done "  book FLIGHTS " > leaks.txt 2> /dev/null && \
		echo "no leaks" || { cat leaks.txt; echo "LEAKS FOUND"; exit 1; }

release: build/tracker-release

clean:
	rm -rf build

.PHONY: run check leaks release clean

-include $(wildcard build/*/*.d)
