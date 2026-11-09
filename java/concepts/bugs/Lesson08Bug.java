// Lesson 08's mistake: a switch expression that forgets one enum value. `make bug N=8` compiles this in.

final class Lesson08Bug {
    private Lesson08Bug() {}

    static String describe(Lesson08Enums.Status status) {
        return switch (status) { // OTHER is missing: javac refuses
            case TODO -> "still to do";
            case DONE -> "finished";
        };
    }

    public static void main(String[] args) {
        System.out.println(describe(Lesson08Enums.Status.DONE));
    }
}
