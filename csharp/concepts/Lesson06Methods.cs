// Lesson 06: methods are C#'s functions, and every one lives in a class. Parameters can have
// defaults and be named when called; `params` takes any number; `out` hands back a second result.
// Lambdas (x => ...) are methods written inline, and they can capture variables around them.
// BUG06: a method with a path that never returns a value.

namespace Concepts;

public static class Lesson06Methods
{
    public const string Title = "Methods and lambdas";

    /// <summary>done out of total, as a percentage; 0 when there's nothing (no dividing by zero).</summary>
    public static double Percent(int done, int total) => total == 0 ? 0 : (double)done / total * 100;

    /// <summary>The tracker's bar: count/biggest of `width` marks, halves rounded to even.</summary>
    public static string Bar(int count, int biggest, int width = 20, char mark = '█') =>
        new(mark, Lesson03Numbers.RoundHalfEven((double)count / biggest * width));

    static int AddAll(params int[] numbers)
    {
        int sum = 0;
        foreach (int n in numbers)
        {
            sum += n;
        }
        return sum;
    }

    /// <summary>The Try pattern: true and the number, or false and a fallback. No exception.</summary>
    public static bool TryParseTop(string text, out int top)
    {
        if (int.TryParse(text, out top) && top >= 1)
        {
            return true;
        }
        top = 3;
        return false;
    }

    static void Bump(int n) => n++; // n is a copy: the caller's variable doesn't change

    static void BumpRef(ref int n) => n++; // ref: n *is* the caller's variable

#if BUG06
    static string Mark(bool done)
    {
        if (done)
        {
            return "x";
        }
    } // and when done is false?
#endif

    public static void Run()
    {
        Console.WriteLine($"Percent(3, 6) = {Percent(3, 6)}, Percent(0, 0) = {Percent(0, 0)}");
        Console.WriteLine($"Bar(2, 3)            = {Bar(2, 3)}");
        Console.WriteLine($"Bar(2, 3, width: 10) = {Bar(2, 3, width: 10)}"); // a named argument
        Console.WriteLine($"Bar(1, 3, mark: '#') = {Bar(1, 3, mark: '#')}");
        Console.WriteLine($"AddAll(1, 2, 3) = {AddAll(1, 2, 3)}");

        foreach (string text in new[] { "5", "zero" })
        {
            bool ok = TryParseTop(text, out int top);
            Console.WriteLine($"TryParseTop(\"{text}\") = {ok}, top = {top}");
        }

        int score = 1;
        Bump(score);
        Console.WriteLine($"after Bump: {score}");
        BumpRef(ref score);
        Console.WriteLine($"after BumpRef: {score}");

        // A local function lives inside the method that uses it.
        static string Plural(int n, string word) => n == 1 ? $"{n} {word}" : $"{n} {word}s";
        Console.WriteLine($"{Plural(1, "task")}, {Plural(6, "task")}");

        // Lambdas are values: Func<in, out> returns something, Action returns nothing.
        Func<string, bool> isTag = word => word.StartsWith('#');
        Console.WriteLine($"isTag(\"#home\") = {isTag("#home")}, isTag(\"home\") = {isTag("home")}");

        int calls = 0;
        Action tick = () => calls++; // a closure: it captures calls itself, not a copy
        tick();
        tick();
        Console.WriteLine($"tick ran {calls} times");
    }
}
