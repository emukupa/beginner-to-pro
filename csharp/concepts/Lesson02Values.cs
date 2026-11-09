// Lesson 02: every value has a type, fixed when the program is compiled. `var` asks the compiler to
// work the type out, but it is still fixed. Value types (int, double, bool, char, tuples) are copied
// when you assign them; reference types (string, arrays, classes) are shared.
// BUG02: reading a variable before it has been given a value. The compiler tracks every path.

namespace Concepts;

public static class Lesson02Values
{
    public const string Title = "Values and types";

    public static void Run()
    {
        int count = 6;
        double percent = 50.0;
        bool done = true;
        char mark = 'x'; // one character, in single quotes
        string title = "Buy groceries";
        Console.WriteLine($"int {count}, double {percent}, bool {done}, char {mark}, string {title}");

        var tags = 2; // var: the compiler sees 2 and makes tags an int, for good
        Console.WriteLine($"var tags is an {tags.GetType().Name}");
        Console.WriteLine($"sizeof(int) = {sizeof(int)}, sizeof(long) = {sizeof(long)}, sizeof(char) = {sizeof(char)}");
        Console.WriteLine($"an int holds {int.MinValue} to {int.MaxValue}");

        const int ChartWidth = 20; // const: worked out when compiling, can never change
        Console.WriteLine($"the chart is {ChartWidth} wide");

        // Value types copy: changing b leaves a alone.
        int a = 1;
        int b = a;
        b++;
        Console.WriteLine($"a = {a}, b = {b}");

        // Reference types share: first and second are two names for one array.
        int[] first = [1, 2];
        int[] second = first;
        second[0] = 99;
        Console.WriteLine($"first[0] = {first[0]} after changing second[0]");

        // A tuple groups a few values without declaring a type. Named parts read better than Item1.
        (string Title, bool Done) task = ("Call mom", true);
        var (name, isDone) = task; // deconstruct: one variable per part
        Console.WriteLine($"tuple {task}, name {name}, done {isDone}");

        // Every type has a default: 0, false, and null for references.
        Console.WriteLine($"default int {default(int)}, default bool {default(bool)}");

#if BUG02
        int doneCount;
        Console.WriteLine(doneCount); // never given a value
#endif
    }
}
