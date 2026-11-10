# Shortcuts for Beginner to Pro. Run `make` to list targets.
# Every language lives in its own folder with its own build; these targets only call the commands
# each language's README and chapter 04 "Done when" document, from the repo root.
.DEFAULT_GOAL := help

LANGUAGES := python c c3 zig cpp rust go node csharp java kotlin swift
# One language (make contract L=rust), or all of them.
L ?= $(LANGUAGES)
# The fuzz test: runs and seed (contract/fuzz.py).
N    ?= 400
SEED ?= 1

RUN := $(CURDIR)/contract/run.sh
# The 8 cases, then the 6 done and 6 undo cases (chapters 03 and 04), against one command.
all_cases = for c in cases done undo; do CASES=$$c $(RUN) $(1) || exit 1; done

# The C++ Makefiles call clang++. CI's Linux runner needs another name and libc++, so it sets
# CPP_CXX (".github/workflows/contract.yml"); on a Mac it stays unset and the Makefiles decide.
CPP_CXX ?=
cpp_cxx = $(if $(CPP_CXX),CXX="$(CPP_CXX)")

# One help section per `## [group]` tag, in this order.
define help_group
	@echo "$(2)"
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## \[$(1)\].*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## \\[$(1)\\] "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
	@echo ""
endef

.PHONY: help contract test fuzz check ci branches \
        $(LANGUAGES:%=contract-%) $(LANGUAGES:%=test-%) $(LANGUAGES:%=build-%) $(LANGUAGES:%=fuzz-%)

help: ## [meta] Show available targets
	$(call help_group,check,Check:)
	$(call help_group,course,Course branches (docs/git-strategy.md):)
	$(call help_group,meta,Meta:)
	@echo "Languages (L=): $(LANGUAGES)"

# ---------- Check ----------
contract: $(L:%=contract-%) ## [check] The contract, every version: one-file (8 cases) and modules (8 + 6 done + 6 undo). L=<lang> for one

test: $(L:%=test-%) ## [check] Each language's own tests, where it has them (L=<lang> for one)

fuzz: ## [check] 400 random runs, Python vs one language's modules version, byte for byte: L=<lang> [N=400] [SEED=1]
	@case "$(L)" in *" "*|"") echo "make fuzz needs one language: L=<lang> ($(LANGUAGES))" >&2; exit 1;; esac
	@$(MAKE) --no-print-directory fuzz-$(L)

check: contract ## [check] What CI runs: the contract for every language (needs all twelve toolchains)

# Runs .github/workflows/contract.yml in local containers with act (`brew install act`; .actrc
# picks the runner image).
#     make ci                          every language
#     make ci ARGS="--matrix language:go"   one
ci: ## [check] Run the GitHub Actions workflow locally with act (ARGS="--matrix language:go" for one)
	@command -v act >/dev/null || { echo "act is not installed: brew install act"; exit 1; }
	act push $(ARGS)

# ---------- Course branches ----------
# WARNING: this MOVES BRANCHES. It force-sets every course/<lang>/NN-slug/start|end branch to its
# chapter commit on course/authoring (git branch -f). Run it only after changing course/authoring,
# as docs/git-strategy.md says; DRY_RUN=1 shows what it would do. It never moves main or pushes.
branches: ## [course] MOVES every course/*/*/start|end branch to course/authoring's chapter commits (DRY_RUN=1 to preview)
	scripts/course-branches.sh

# ---------- Per language ----------
# contract-<lang>: the commands from <lang>/README.md and <lang>/chapters/04-undo/CHAPTER.md.
# build-<lang>:    builds the modules version that fuzz-<lang> runs; FUZZ_<lang> is its command.

contract-python:
	$(call all_cases,python3 "$(CURDIR)/python/tasks.py")

contract-c:
	$(MAKE) -C c/one-file check
	$(MAKE) -C c/modules check

contract-c3:
	$(MAKE) -C c3/one-file check
	$(MAKE) -C c3/modules check

contract-zig:
	cd zig/one-file && zig build check
	cd zig/modules && zig build check

contract-cpp:
	$(MAKE) -C cpp/one-file check $(cpp_cxx)
	$(MAKE) -C cpp/modules check $(cpp_cxx)

contract-rust: build-rust
	cd rust/one-file && cargo build && $(RUN) "$$PWD/target/debug/tracker"
	$(call all_cases,$(FUZZ_rust))

contract-go: build-go
	cd go && go build -o one-file/build/tracker ./one-file && $(RUN) "$$PWD/one-file/build/tracker"
	$(call all_cases,$(FUZZ_go))

contract-node:
	$(RUN) node "$(CURDIR)/node/one-file/tracker.ts"
	$(call all_cases,$(FUZZ_node))

contract-csharp: build-csharp
	cd csharp/one-file && dotnet build -c Release -o build && $(RUN) "$$PWD/build/tracker"
	$(call all_cases,$(FUZZ_csharp))

contract-java: build-java
	$(RUN) java "$(CURDIR)/java/one-file/Tracker.java"
	$(call all_cases,$(FUZZ_java))

contract-kotlin: build-kotlin
	$(MAKE) -C kotlin/one-file check
	$(call all_cases,$(FUZZ_kotlin))

contract-swift: build-swift
	$(MAKE) -C swift/one-file check
	$(call all_cases,$(FUZZ_swift))

FUZZ_python := python3 "$(CURDIR)/python/tasks.py"
FUZZ_c      := "$(CURDIR)/c/modules/build/tracker"
FUZZ_c3     := "$(CURDIR)/c3/modules/build/tracker"
FUZZ_zig    := "$(CURDIR)/zig/modules/zig-out/bin/tracker"
FUZZ_cpp    := "$(CURDIR)/cpp/modules/build/tracker"
FUZZ_rust   := "$(CURDIR)/rust/modules/target/debug/tracker"
FUZZ_go     := "$(CURDIR)/go/modules/build/tracker"
FUZZ_node   := node "$(CURDIR)/node/modules/tracker/cli.ts"
FUZZ_csharp := "$(CURDIR)/csharp/modules/build/tracker"
FUZZ_java   := java -p "$(CURDIR)/java/modules/build" -m tracker.app/tracker.app.Main
FUZZ_kotlin := "$(CURDIR)/kotlin/modules/app/build/install/tracker/bin/tracker"
FUZZ_swift  := "$(CURDIR)/swift/modules/.build/release/tracker"

build-python build-node:
	@true
build-c:
	$(MAKE) -C c/modules build/tracker
build-c3:
	$(MAKE) -C c3/modules build/tracker
build-zig:
	cd zig/modules && zig build
build-cpp:
	$(MAKE) -C cpp/modules build/tracker $(cpp_cxx)
build-rust:
	cd rust/modules && cargo build
build-go:
	cd go && go build -o modules/build/tracker ./modules
build-csharp:
	cd csharp/modules && dotnet build Cli -c Release -o build
build-java:
	$(MAKE) -C java/modules build
build-kotlin:
	cd kotlin/modules && ./gradlew installDist
build-swift:
	cd swift/modules && swift build -c release

$(LANGUAGES:%=fuzz-%): fuzz-%: build-%
	contract/fuzz.py --runs $(N) --seed $(SEED) -- $(FUZZ_$*)

# test-<lang>: the tests each README documents. Python, C, C3 and C++ have none yet; their
# chapters are checked by the contract (and C, C3 and C++ by their sanitizers or safe builds).
test-python test-c test-c3 test-cpp:
	@echo "$(@:test-%=%): no unit tests; the contract checks it (make contract L=$(@:test-%=%))"

test-zig:
	cd zig/concepts && zig build test

test-rust:
	cd rust/concepts && cargo test
	cd rust/modules && cargo test

test-go:
	cd go && go test ./...

test-node:
	cd node && npm ci && npm test

test-csharp:
	cd csharp/concepts.tests && dotnet test
	cd csharp/modules && dotnet test

test-java:
	$(MAKE) -C java/concepts test
	$(MAKE) -C java/modules test

test-kotlin:
	$(MAKE) -C kotlin/concepts test
	cd kotlin/modules && ./gradlew test

test-swift:
	cd swift/concepts && swift test
	cd swift/modules && swift test
