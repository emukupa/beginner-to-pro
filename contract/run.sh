#!/usr/bin/env bash
# The behaviour every version of the tracker must match, in any language.
#   contract/run.sh <command...>          check   e.g. contract/run.sh python3 "$PWD/python/tasks.py"
#   RECORD=1 contract/run.sh <command...> write the expected files from a reference version
# Each case runs in a fresh folder holding tasks.txt (plus the case's own files), with the case's
# stdin, arguments and environment. Compared: stdout, stderr, the exit code, and tasks.txt afterwards.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
fail=0
for case in "$here"/cases/*/; do
  name="$(basename "$case")"
  work="$(mktemp -d)"
  cp "$here/tasks.txt" "$work/"
  find "$case" -maxdepth 1 -name '*.txt' -exec cp {} "$work/" \;
  read -r -a args < <(cat "$case/args"; echo)
  read -r -a envs < <(cat "$case/env"; echo)
  (cd "$work" && env ${envs[@]+"${envs[@]}"} "$@" ${args[@]+"${args[@]}"} < "$case/stdin" > out 2> err; echo $? > code)
  if [[ -n "${RECORD:-}" ]]; then
    cp "$work/out" "$case/expected_stdout"; cp "$work/err" "$case/expected_stderr"
    cp "$work/code" "$case/expected_exit"; cp "$work/tasks.txt" "$case/expected_tasks.txt"
    echo "recorded $name"
  else
    bad=""
    cmp -s "$work/out" "$case/expected_stdout" || bad+=" stdout"
    cmp -s "$work/err" "$case/expected_stderr" || bad+=" stderr"
    cmp -s "$work/code" "$case/expected_exit" || bad+=" exit"
    cmp -s "$work/tasks.txt" "$case/expected_tasks.txt" || bad+=" tasks.txt"
    if [[ -z "$bad" ]]; then echo "pass  $name"; else
      echo "FAIL  $name:$bad"; fail=1
      for f in out err; do diff -u "$case/expected_std${f/err/err}" "$work/$f" 2>/dev/null | head -20; done
    fi
  fi
  rm -rf "$work"
done
exit $fail
