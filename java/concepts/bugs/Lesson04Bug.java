// Lesson 04's mistake: indexing a String as if it were an array. `make bug N=4` compiles this in.

final class Lesson04Bug {
    private Lesson04Bug() {}

    public static void main(String[] args) {
        String title = "Fix login bug";
        char first = title[0]; // a String isn't an array: charAt(0) is how you ask
        System.out.println(first);
    }
}
