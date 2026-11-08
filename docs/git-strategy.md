# Git strategy

The same start/end-branch-per-lesson pattern as atlas, with the language as part of every
course branch's name.

## Branches

| Branch | Lifetime | Rule |
| --- | --- | --- |
| `main` | permanent | The latest finished code for every language. Moves to the tip of `course/authoring`. |
| `course/authoring` | permanent | Linear. One commit per chapter start and end, every language in one history. |
| `course/<lang>/NN-slug/start` | regenerated | Where a student begins chapter NN of that language. |
| `course/<lang>/NN-slug/end` | regenerated | The reference solution for chapter NN. |

## Rules

1. `course/<lang>/NN/start` = `course/<lang>/(NN-1)/end` + `<lang>/chapters/NN-slug/CHAPTER.md`
   + any `TODO(chNN)` stubs.
2. Chapter commits on `course/authoring` use these exact subjects:
   - `chapter(python/01-one-file): start`
   - `chapter(python/01-one-file): end`
3. After any change to `course/authoring`, run `scripts/course-branches.sh`. It moves every
   `course/*/*/start|end` branch to its commit.
4. Every `end` commit passes the contract: `contract/run.sh <command for that language>`.
5. Languages live in their own folders and never import from each other, so a fix in one
   language's chapter can't break another's.
6. Tag the commit each video was recorded on: `video/python-001`, `video/python-002`, and so on.
   A tag never moves, so a video's description can always link to the exact code it shows.

## Fixing an earlier chapter

```bash
git switch course/authoring
git rebase -i --root               # mark the chapter commit as "edit"
# ...make the fix, git add...
git commit --amend --no-edit
git rebase --continue              # resolve forward, chapter by chapter
scripts/course-branches.sh         # regenerate course/*/*/start|end
git branch -f main course/authoring
git push --force-with-lease origin main 'refs/heads/course/*'
```

Video tags keep pointing at the old commits on purpose: they show what was on screen.

## Adding a chapter

```bash
git switch course/authoring
# add <lang>/chapters/NN-slug/CHAPTER.md and any TODO stubs
git commit -m "chapter(<lang>/NN-slug): start"
# implement the solution; contract/run.sh must pass
git commit -m "chapter(<lang>/NN-slug): end"
scripts/course-branches.sh
git branch -f main course/authoring
```
