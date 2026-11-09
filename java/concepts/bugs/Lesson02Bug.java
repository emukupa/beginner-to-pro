// Lesson 02's mistake: changing a final variable. `make bug N=2` compiles this file in.

final class Lesson02Bug {
    private Lesson02Bug() {}

    public static void main(String[] args) {
        final int width = 20;
        width = 30; // final means set once: javac refuses
        System.out.println(width);
    }
}
