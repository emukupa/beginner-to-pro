# Safe C concepts. Same strict flags and sanitizers as the tracker.
#   make            build/concepts, then every lesson
#   make 07         lesson 7 alone
#   make 07 BUG=1   lesson 7 with its Safe C bug compiled in
#   make solo-07    lesson 7 built on its own (solo.c), with only the lessons it includes
CC      ?= cc
CFLAGS  := -std=c23 -Wall -Wextra -Wpedantic -Wconversion -Wshadow -Werror -g
SAN     := -fsanitize=address,undefined -fno-sanitize-recover=all -fno-omit-frame-pointer
LESSONS := 01 02 03 04 05 06 07 08 09 10 11 12 13 14

all: build/concepts
	./build/concepts

build/concepts: main.c concepts.h $(wildcard lesson_*.c) | build
	$(CC) $(CFLAGS) $(SAN) -o $@ main.c -lm

ifdef BUG
$(LESSONS): | build
	$(CC) $(CFLAGS) $(SAN) -DBUG=$(patsubst 0%,%,$@) -o build/concepts-bug main.c -lm
	./build/concepts-bug $@
else
$(LESSONS): build/concepts
	./build/concepts $@
endif

# A lesson alone doesn't call every function of the earlier lessons it includes, so unused
# functions are allowed here (and only here). BUG=1 works too: make solo-07 BUG=1.
SOLO := $(addprefix solo-,$(LESSONS))
$(SOLO): solo-%: | build
	$(CC) $(CFLAGS) -Wno-unused-function $(SAN) $(if $(BUG),-DBUG=$(patsubst 0%,%,$*)) \
		-DLESSON_FILE='"$(wildcard lesson_$*_*.c)"' -DLESSON_RUN=lesson_$* -o build/$@ solo.c -lm
	./build/$@

build:
	mkdir -p build

clean:
	rm -rf build

.PHONY: all clean $(LESSONS) $(SOLO)
