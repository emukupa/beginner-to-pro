# C3 concepts. -O0 is C3's safe mode: bounds, null and contract checks are all on.
#   make            build/concepts, then every lesson
#   make 07         lesson 7 alone
#   make 07 BUG=1   lesson 7 with its mistake compiled in (-D BUG07): watch C3 catch it
C3C     ?= c3c
SOURCES := main.c3 $(wildcard lesson_*.c3)
LESSONS := 01 02 03 04 05 06 07 08 09 10 11 12 13 14

all: build/concepts
	./build/concepts

build/concepts: $(SOURCES) | build
	$(C3C) compile -q -O0 -o $@ $(SOURCES)

ifdef BUG
$(LESSONS): | build
	$(C3C) compile -q -O0 -D BUG$@ -o build/concepts-bug $(SOURCES)
	./build/concepts-bug $@
else
$(LESSONS): build/concepts
	./build/concepts $@
endif

build:
	mkdir -p build

clean:
	rm -rf build

.PHONY: all clean $(LESSONS)
