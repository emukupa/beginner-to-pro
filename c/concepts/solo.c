// Builds one lesson on its own: make solo-07. The Makefile passes the lesson's file and its run
// function, so this is the whole program: that lesson, the earlier lessons it includes, and main.
#include "concepts.h"
#include LESSON_FILE

int main(void) {
    LESSON_RUN();
    return 0;
}
