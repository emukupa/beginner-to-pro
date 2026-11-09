# Kotlin concepts, built with plain kotlinc: no Gradle, nothing to download.
#   make              build build/concepts.jar (about 10 seconds: kotlinc starts a JVM and is thorough)
#   make run          build if needed, then every lesson        make run N=7   just lesson 7
#   make bug N=7      lesson 7 with bugs/Lesson07Bug.kt compiled in: watch kotlinc (or the JVM) catch it
#   make test         the tests in test/, written with kotlin.test
#   make clean        delete build/

# -Werror: a warning fails the build, so warnings can't pile up unread. kotlinc warns about things
# like a deprecated call, a redundant cast, or ?. and !! on a value that can't be null. (Unused
# variables are flagged by the IDE, not by kotlinc.)
KOTLINC := kotlinc -Werror
SOURCES := $(wildcard src/*.kt)

# kotlin-test.jar ships with the compiler, next to the standard library. Homebrew keeps it in
# libexec/lib, the zip from GitHub in lib. Override with: make test KOTLIN_LIB=/path/to/lib
KOTLINC_HOME := $(dir $(realpath $(shell command -v kotlinc)))..
KOTLIN_LIB ?= $(firstword $(wildcard $(KOTLINC_HOME)/libexec/lib $(KOTLINC_HOME)/lib))
KOTLIN_TEST := $(KOTLIN_LIB)/kotlin-test.jar

# The bug file for lesson N: N=7 -> bugs/Lesson07Bug.kt
NN = $(shell printf '%02d' $(N))

.PHONY: all run bug test clean

all: build/concepts.jar

# -include-runtime puts the Kotlin standard library in the jar, so `java -jar` can run it alone.
build/concepts.jar: $(SOURCES)
	@mkdir -p build
	$(KOTLINC) $(SOURCES) -include-runtime -d $@

run: build/concepts.jar
	java -jar build/concepts.jar $(N)

bug:
	@test -n "$(N)" || { echo "Which lesson? make bug N=7"; exit 2; }
	@mkdir -p build
	$(KOTLINC) $(SOURCES) bugs/Lesson$(NN)Bug.kt -include-runtime -d build/bug$(NN).jar
	java -jar build/bug$(NN).jar $(N)

build/tests.jar: build/concepts.jar $(wildcard test/*.kt)
	$(KOTLINC) -cp build/concepts.jar:$(KOTLIN_TEST) $(wildcard test/*.kt) -d $@

test: build/tests.jar
	java -cp build/concepts.jar:build/tests.jar:$(KOTLIN_TEST) concepts.tests.ConceptsTestKt

clean:
	rm -rf build
