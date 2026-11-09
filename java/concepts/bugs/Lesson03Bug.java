// Lesson 03's mistake: a double result stored in an int. `make bug N=3` compiles this file in.

final class Lesson03Bug {
    private Lesson03Bug() {}

    public static void main(String[] args) {
        int width = 20 * 0.65; // 13.0 is a double: javac won't drop the fraction without a cast
        System.out.println(width);
    }
}
