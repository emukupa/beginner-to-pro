// Lesson 10's mistake: @Override on a method that doesn't override anything (toString misspelt).
// `make bug N=10` compiles this file in.

import java.util.List;

final class Lesson10Bug {
    private Lesson10Bug() {}

    static class UrgentTask extends Lesson09Classes.Task {
        UrgentTask(String title) {
            super(title, Lesson08Enums.Status.TODO, List.of("urgent"));
        }

        @Override
        public String toStrng() { // Task has no toStrng to replace: javac refuses
            return super.toString() + "  !!";
        }
    }

    public static void main(String[] args) {
        System.out.println(new UrgentTask("Finish quarterly report"));
    }
}
