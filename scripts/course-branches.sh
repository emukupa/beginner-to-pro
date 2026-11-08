#!/usr/bin/env bash
# Regenerate course/<lang>/NN-slug/start and course/<lang>/NN-slug/end branches from the
# "chapter(<lang>/NN-slug): start|end" commits on course/authoring.
# (The same pattern as atlas, with the language as the first part of the name.)
#
# Usage: scripts/course-branches.sh [authoring-branch]
#        DRY_RUN=1 scripts/course-branches.sh
set -euo pipefail

AUTHORING="${1:-course/authoring}"

if ! git rev-parse --verify --quiet "$AUTHORING" >/dev/null; then
  echo "No branch '$AUTHORING'." >&2
  exit 1
fi

count=0
while IFS=$'\t' read -r sha subject; do
  if [[ "$subject" =~ ^chapter\(([a-z0-9]+/[0-9]{2}-[a-z0-9-]+)\):\ (start|end)$ ]]; then
    slug="${BASH_REMATCH[1]}"
    phase="${BASH_REMATCH[2]}"
    branch="course/${slug}/${phase}"
    if [[ -n "${DRY_RUN:-}" ]]; then
      echo "would set ${branch} -> ${sha:0:8}"
    else
      git branch -f "$branch" "$sha" >/dev/null
      echo "set ${branch} -> ${sha:0:8}"
    fi
    count=$((count + 1))
  fi
done < <(git log --reverse --format='%H%x09%s' "$AUTHORING")

echo "${count} course branches from ${AUTHORING}"
