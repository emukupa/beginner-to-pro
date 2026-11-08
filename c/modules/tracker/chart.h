// Drawing the tag chart. Knows nothing about tasks: it takes (label, count) pairs and a stream.
#pragma once
#include <stdio.h>

#include "tasklist.h"

void draw_chart(FILE *out, const TagList *pairs, size_t width, const char *bar_char);
