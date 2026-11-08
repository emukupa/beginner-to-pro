// One line of text into a task: the only place that knows the file format.
#pragma once
#include "models.h"

static constexpr char TAG_MARKER = '#';  // marks a word as a tag: "#work"

// Turns "[done.] Call mom #family" into *out, which the caller then owns. False if not a task.
[[nodiscard]] bool parse_line(const char *line, Task *out);
