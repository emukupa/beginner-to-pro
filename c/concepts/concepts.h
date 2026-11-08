// Everything a lesson needs from C's standard library, in one place. Every lesson includes this, so
// any lesson compiles on its own (make solo-07) as well as inside main.c.
#pragma once

#define _POSIX_C_SOURCE 200809L  // getline()

#include <ctype.h>
#include <errno.h>
#include <limits.h>
#include <math.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef BUG
#define BUG 0  // make NN BUG=1 sets it to the lesson's number, compiling that lesson's bug in
#endif
