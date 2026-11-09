// Lesson 05: decisions and loops. `if` and `switch` choose; a switch expression gives back a value,
// and its patterns can test ranges (< 0, >= 50 and < 100).
// BUG05: a switch case that runs on into the next one. C# never falls through silently.

namespace Concepts;

public static class Lesson05Control
{
    public const string Title = "Control flow";

    public static string Describe(int count) => count switch
    {
        < 0 => "impossible",
        0 => "none",
        1 => "one",
        _ => "many", // _ matches anything left
    };

    public static void Run()
    {
        int done = 3, total = 6;
        if (done == total)
        {
            Console.WriteLine("all done");
        }
        else if (done == 0)
        {
            Console.WriteLine("not started");
        }
        else
        {
            Console.WriteLine($"{total - done} to go");
        }
        string word = done * 2 >= total ? "half or more" : "less than half"; // ?: is an if that gives a value
        Console.WriteLine(word);

        for (int i = 1; i <= 3; i++)
        {
            Console.Write($"{i} ");
        }
        Console.WriteLine();

        foreach (string line in new[] { "[done] Buy groceries", "", "# a comment", "[todo] Book flights" })
        {
            if (line.Length == 0 || line.StartsWith('#'))
            {
                continue; // skip to the next line
            }
            Console.WriteLine($"line: {line}");
        }

        int left = 20;
        while (left > 1)
        {
            left /= 2;
        }
        Console.WriteLine($"halved down to {left}");

        // A switch statement: every section ends with break (or return). Stacked labels share one.
        foreach (string status in new[] { "done", "todo", "doing" })
        {
            switch (status)
            {
                case "done":
                    Console.WriteLine("done: tick it");
                    break;
                case "todo":
                case "doing":
                    Console.WriteLine($"{status}: still open");
                    break;
                default:
                    Console.WriteLine("unknown");
                    break;
            }
        }

        int percent = 50;
        string verdict = percent switch
        {
            100 => "finished",
            >= 50 and < 100 => "past halfway", // relational and logical patterns
            _ => "early days",
        };
        Console.WriteLine($"{percent}%: {verdict}; Describe 0, 1, 6: {Describe(0)}, {Describe(1)}, {Describe(6)}");

#if BUG05
        switch (word)
        {
            case "half or more":
                Console.WriteLine("good"); // no break: would run straight into the next case
            case "less than half":
                Console.WriteLine("keep going");
                break;
        }
#endif
    }
}
