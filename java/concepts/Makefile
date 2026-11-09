# Java concepts. Plain javac and java, no build tool: make only saves typing the same lines.
#   make            build, then run every lesson
#   make run N=7    just lesson 7
#   make bug N=7    lesson 7 with its mistake (bugs/Lesson07Bug.java) compiled in
#   make test       the checks in Tests.java, with assertions switched on (-ea)
#   make clean      delete build/

# -Xlint:all turns on every warning javac has; -Werror makes each one stop the build.
JAVAC = javac -Xlint:all -Werror
N ?= 1
NN = $(shell printf %02d $(N))

.PHONY: all build run bug test clean

all: build
	java -cp build Main

build:
	$(JAVAC) -d build *.java

run: build
	java -cp build Main $(N)

# The lessons plus one bug file, into a separate folder so the normal build never sees it.
bug:
	$(JAVAC) -d build/bug *.java bugs/Lesson$(NN)Bug.java
	java -cp build/bug Lesson$(NN)Bug

test: build
	java -ea -cp build Tests

clean:
	rm -rf build
