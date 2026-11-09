// Lesson 01's mistake: a typo in a function's name. kotlinc checks every name before the program
// exists, so it's caught here, not when the line finally runs.
package concepts.lesson01

fun bug() {
    printn("Hello again")
}
