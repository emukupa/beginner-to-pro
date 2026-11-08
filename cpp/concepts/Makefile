# C++ concepts. The same strict flags and sanitizers the tracker will use.
#   make            build/concepts, then every lesson
#   make 07         lesson 7 alone
#   make 07 BUG=1   lesson 7 with its deliberate mistake compiled in
CXX      = clang++
CXXFLAGS := -std=c++23 -Wall -Wextra -Wpedantic -Wconversion -Wshadow -Werror -g
SAN      := -fsanitize=address,undefined -fno-sanitize-recover=all -fno-omit-frame-pointer
LESSONS  := 01 02 03 04 05 06 07 08 09 10 11 12 13 14

all: build/concepts
	./build/concepts

build/concepts: main.cpp concepts.hpp $(wildcard lesson_*.cpp) | build
	$(CXX) $(CXXFLAGS) $(SAN) -o $@ main.cpp

# BUG=1 builds a separate binary with -DBUG=7 (the leading 0 dropped), so only lesson 7's mistake
# is compiled in, then runs just that lesson.
ifdef BUG
$(LESSONS): | build
	$(CXX) $(CXXFLAGS) $(SAN) -DBUG=$(patsubst 0%,%,$@) -o build/concepts-bug main.cpp
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
