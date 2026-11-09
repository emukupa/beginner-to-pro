// Lesson 01's mistake: println misspelt. `make bug N=1` compiles this file in with the lessons.

final class Lesson01Bug {
    private Lesson01Bug() {}

    public static void main(String[] args) {
        System.out.printn("Hello, tasks!"); // there is no printn: javac refuses to build
    }
}
