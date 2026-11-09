# The tracker as two Java modules: tracker.core (one package per job) and tracker.app (the program).
#   make                 compile both modules into build/, with every lint warning as an error
#   make run             run it on tasks.txt here
#   make test            the tests in test/, plain assert statements run with java -ea
#   make check           the contract: must match Python byte for byte
JAVAC = javac -Xlint:all -Werror
SOURCES = $(shell find src -name '*.java')

build: $(SOURCES)
	$(JAVAC) -d build --module-source-path src $(SOURCES)
	@touch build

run: build
	java -p build -m tracker.app/tracker.app.Main

test: build
	$(JAVAC) -d build/test -cp build/tracker.core test/tracker/tests/Tests.java
	java -ea -cp build/tracker.core:build/test tracker.tests.Tests

check: build
	../../contract/run.sh java -p "$(CURDIR)/build" -m tracker.app/tracker.app.Main

.PHONY: run test check
