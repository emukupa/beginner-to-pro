#include "models.h"

#include <stdlib.h>

void strlist_free(StringList *list) {
    for (size_t i = 0; i < list->len; i++) free(list->items[i]);
    free(list->items);
    *list = (StringList){};
}

bool task_is_done(const Task *t) { return t->status == STATUS_DONE; }

void task_write(const Task *t, FILE *out) {
    fprintf(out, "[%c] %s%s\n", task_is_done(t) ? 'x' : ' ', t->title, t->kind == TASK_URGENT ? "  !!" : "");
}

void task_free(Task *t) {
    free(t->title);
    strlist_free(&t->tags);
}
