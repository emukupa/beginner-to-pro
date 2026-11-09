# The task tracker in one Kotlin file, compiled into a jar that runs on the JVM.
#   make            kotlinc -Werror tracker.kt into build/tracker.jar (it takes a few seconds)
#   make run        run it on tasks.txt here
#   make check      the contract: must match Python byte for byte
build/tracker.jar: tracker.kt
	kotlinc -Werror tracker.kt -include-runtime -d build/tracker.jar

run: build/tracker.jar
	java -jar build/tracker.jar

check: build/tracker.jar
	../../contract/run.sh java -jar "$(CURDIR)/build/tracker.jar"

.PHONY: run check
