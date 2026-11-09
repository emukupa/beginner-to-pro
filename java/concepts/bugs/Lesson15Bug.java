// Lesson 15's mistake: a new command that isn't in Command's permits list.
// `make bug N=15` compiles this file in.

final class Lesson15Bug {
    private Lesson15Bug() {}

    record Delete(String title) implements Lesson15Sealed.Command {} // not permitted: javac refuses

    public static void main(String[] args) {
        System.out.println(new Delete("Call mom"));
    }
}
