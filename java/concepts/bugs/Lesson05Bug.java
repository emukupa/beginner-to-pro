// Lesson 05's mistake: a variable set on only one path, then read. `make bug N=5` compiles this in.

final class Lesson05Bug {
    private Lesson05Bug() {}

    public static void main(String[] args) {
        boolean done = args.length > 0;
        String mark;
        if (done) {
            mark = "x";
        }
        System.out.println(mark); // when done is false, mark was never set: javac refuses
    }
}
