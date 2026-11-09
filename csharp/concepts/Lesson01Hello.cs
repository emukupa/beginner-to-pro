// Lesson 01: a C# program starts at the first statement in Program.cs (top-level statements); each
// lesson here is a Run() method. Console.WriteLine prints a line. A string starting with $ is
// interpolated: {name} inside it prints that value, checked by the compiler.
// BUG01: a variable that's set and never read. That's a warning, and warnings are errors here.

namespace Concepts;

public static class Lesson01Hello
{
    public const string Title = "Hello";

    public static void Run()
    {
        Console.WriteLine("Hello, tasks!");
        int count = 6;
        Console.WriteLine($"{count} tasks in the file"); // {count} prints the variable
        Console.WriteLine("{0} of {1} done", 3, count); // the older way: numbered holes, filled in order
        Console.WriteLine($"[{"work",-8}] [{"home",8}]"); // ,-8 pads on the right to 8 wide, ,8 on the left
        Console.Write("Write adds no newline, ");
        Console.WriteLine("so this ends the same line");
        // Console.Error.WriteLine prints to stderr instead, for errors. Program.cs returns an exit
        // code: 0 means it worked.

#if BUG01
        int total = 6; // given a value that nothing ever reads
#endif
    }
}
