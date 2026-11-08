#!/usr/bin/env bash
# The behaviour every version of the tracker must match, in any language.
#   contract/run.sh <command...>          check   e.g. contract/run.sh python3 "$PWD/python/tasks.py"
#   RECORD=1 contract/run.sh <command...> write the expected files from a reference version
#   CASES=done contract/run.sh <command...> the done-command cases (chapter 03 onwards)
#   CASES=undo contract/run.sh <command...> the undo-command cases (chapter 04 onwards)
# Each case runs in a fresh folder holding tasks.txt (plus the case's own files), with the case's
# stdin, arguments (one per line in args) and environment (NAME=value, one per line in env).
# Compared: stdout, stderr, the exit code, and tasks.txt (and any file the case brings) afterwards.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
fail=0
for case in "$here/${CASES:-cases}"/*/; do
  name="$(basename "$case")"
  work="$(mktemp -d)"
  cp "$here/tasks.txt" "$work/"
  extra=(); for f in "$case"*.txt; do [[ -e "$f" && "$(basename "$f")" != expected_* ]] && extra+=("$(basename "$f")"); done
  for f in ${extra[@]+"${extra[@]}"}; do cp "$case$f" "$work/"; done
  args=(); while IFS= read -r a || [[ -n "$a" ]]; do args+=("$a"); done < "$case/args"
  envs=(); while IFS= read -r v || [[ -n "$v" ]]; do envs+=("$v"); done < "$case/env"
  (cd "$work" && env ${envs[@]+"${envs[@]}"} "$@" ${args[@]+"${args[@]}"} < "$case/stdin" > out 2> err; echo $? > code)
  if [[ -n "${RECORD:-}" ]]; then
    cp "$work/out" "$case/expected_stdout"; cp "$work/err" "$case/expected_stderr"
    cp "$work/code" "$case/expected_exit"; cp "$work/tasks.txt" "$case/expected_tasks.txt"
    for f in ${extra[@]+"${extra[@]}"}; do cp "$work/$f" "$case/expected_$f"; done
    echo "recorded $name"
  else
    bad=""
    cmp -s "$work/out" "$case/expected_stdout" || bad+=" stdout"
    cmp -s "$work/err" "$case/expected_stderr" || bad+=" stderr"
    cmp -s "$work/code" "$case/expected_exit" || bad+=" exit"
    cmp -s "$work/tasks.txt" "$case/expected_tasks.txt" || bad+=" tasks.txt"
    for f in ${extra[@]+"${extra[@]}"}; do cmp -s "$work/$f" "$case/expected_$f" || bad+=" $f"; done
    if [[ -z "$bad" ]]; then echo "pass  $name"; else
      echo "FAIL  $name:$bad"; fail=1
      for f in out err; do diff -u "$case/expected_std${f/err/err}" "$work/$f" 2>/dev/null | head -20; done
    fi
  fi
  rm -rf "$work"
done
exit $fail
