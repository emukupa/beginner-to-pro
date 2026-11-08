#include "chart.h"

#include <math.h>

#include "text.h"

void draw_chart(FILE *out, const TagList *pairs, size_t width, const char *bar_char) {
    if (pairs->len == 0) {
        fputs("No tags yet.\n", out);
        return;
    }
    size_t biggest = pairs->items[0].count;
    size_t label_width = 0;
    for (size_t i = 0; i < pairs->len; i++) {
        size_t w = text_width(pairs->items[i].tag);
        if (w > label_width) label_width = w;
    }
    for (size_t i = 0; i < pairs->len; i++) {
        const TagCount *p = &pairs->items[i];
        // nearbyint rounds halves to even, like Python's round(): 2.5 -> 2
        size_t bar = (size_t)nearbyint((double)p->count / (double)biggest * (double)width);
        fprintf(out, "%s%*s  ", p->tag, (int)(label_width - text_width(p->tag)), "");
        for (size_t b = 0; b < bar; b++) fputs(bar_char, out);
        fprintf(out, " %zu\n", p->count);
    }
}
