// Lesson 09's mistake: writing to a Task's private field. `make bug N=9` compiles this file in.

final class Lesson09Bug {
    private Lesson09Bug() {}

    public static void main(String[] args) {
        Lesson09Classes.Task task = new Lesson09Classes.Task("Call mom");
        task.title = "Call dad"; // title is private to Task: javac refuses
        System.out.println(task);
    }
}
