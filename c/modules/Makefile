# Safe C build. Every build is strict; `make check` runs the contract under the sanitizers.
#   make            build/tracker: AddressSanitizer + UndefinedBehaviorSanitizer, for development
#   make run        build if needed, then run it here (make run ARGS=work.txt passes arguments)
#   make check      the contract against build/tracker
#   make leaks      one full run under macOS's leaks tool (ASan can't check leaks on macOS)
#   make release    build/tracker-release: optimised, no sanitizers
# Each module compiles to its own object file, so changing one .c rebuilds only that file, and
# -MMD records which headers each one includes, so changing a .h rebuilds exactly the files using it.
CC      ?= cc
CFLAGS  := -std=c23 -Wall -Wextra -Wpedantic -Wconversion -Wshadow -Werror -g -MMD -MP
SAN     := -fsanitize=address,undefined -fno-sanitize-recover=all -fno-omit-frame-pointer
SOURCES := $(wildcard tracker/*.c)

build/tracker: $(SOURCES:tracker/%.c=build/san/%.o)
	$(CC) $(SAN) -o $@ $^ -lm

build/tracker-plain: $(SOURCES:tracker/%.c=build/plain/%.o)
	$(CC) -o $@ $^ -lm

build/tracker-release: $(SOURCES:tracker/%.c=build/release/%.o)
	$(CC) -o $@ $^ -lm

build/san/%.o: tracker/%.c | build/san
	$(CC) $(CFLAGS) $(SAN) -c -o $@ $<

build/plain/%.o: tracker/%.c | build/plain
	$(CC) $(CFLAGS) -c -o $@ $<

build/release/%.o: tracker/%.c | build/release
	$(CC) $(CFLAGS) -O2 -c -o $@ $<

build/san build/plain build/release:
	mkdir -p $@

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

-include $(wildcard build/*/*.d)
