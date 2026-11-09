// Lesson 07's mistake: i <= length instead of i < length, so the last step reads one past the end.
// It compiles; `make bug N=7` runs it and Java stops it with an exception.

final class Lesson07Bug {
    private Lesson07Bug() {}

    public static void main(String[] args) {
        String[] titles = {"Buy groceries", "Call mom", "Book flights"};
        for (int i = 0; i <= titles.length; i++) {
            System.out.println(titles[i]);
        }
    }
}
