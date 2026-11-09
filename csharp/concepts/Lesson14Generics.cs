// Lesson 14: a generic method works for any type; a constraint (`where`) says what that type must be
// able to do, and the compiler checks every call. TopN works on tag counts, tasks, anything with a
// key that can be compared.
// Then everything so far comes together: a mini tracker, run on tasks.txt.
// BUG14: TopN with a key that can't be compared (a string[]).

namespace Concepts;

public static class Lesson14Generics
{
    public const string Title = "Generics, and a mini tracker";

    /// <summary>The n items with the biggest keys; ties keep their order. Without the constraint,
    /// a key that can't be compared would only fail when the program runs.</summary>
    public static List<T> TopN<T, TKey>(IEnumerable<T> items, Func<T, TKey> key, int n)
        where TKey : IComparable<TKey>
    {
        if (n < 1)
        {
            throw new ArgumentOutOfRangeException(nameof(n), n, "n must be at least 1");
        }
        return items.OrderByDescending(key).Take(n).ToList();
    }

    /// <summary>The tracker's chart: labels padded by characters, the biggest bar 20 wide.</summary>
    public static void DrawChart(IReadOnlyList<TagCount> pairs, int width = 20)
    {
        if (pairs.Count == 0)
        {
            Console.WriteLine("No tags yet.");
            return;
        }
        int biggest = pairs[0].Count;
        int labelWidth = pairs.Max(p => Lesson04Strings.TextWidth(p.Tag));
        foreach (var (tag, count) in pairs)
        {
            Console.WriteLine($"{Lesson04Strings.PadByWidth(tag, labelWidth)}  {Lesson06Methods.Bar(count, biggest, width)} {count}");
        }
    }

    public static void Run()
    {
        List<Task> tasks = Lesson11Errors.LoadTasks(Lesson11Errors.TasksFile);
        int top;
        try
        {
            top = Lesson11Errors.ParseTop("3"); // the tracker asks; here the answer is fixed
        }
        catch (Exception e) when (e is FormatException or ArgumentOutOfRangeException)
        {
            top = 3;
        }

        List<TagCount> pairs = TopN(Lesson12Collections.CountTags(tasks), c => c.Count, top);
        int done = tasks.Count(t => t.IsDone);
        int tags = tasks.SelectMany(t => t.Tags).Distinct().Count();
        int percent = Lesson03Numbers.RoundHalfEven(Lesson06Methods.Percent(done, tasks.Count));

        Console.WriteLine($"{tasks.Count} tasks, {done} done ({percent}%), {tags} tags");
        foreach (Task task in tasks)
        {
            if (task is UrgentTask && !task.IsDone)
            {
                Console.WriteLine(task);
            }
        }
        Console.WriteLine();
        Console.WriteLine("Top tags");
        DrawChart(pairs);

        // The same TopN, a different T: the two longest titles.
        Console.WriteLine();
        Console.WriteLine($"longest titles: {string.Join(", ", TopN(tasks, t => t.Title.Length, 2).Select(t => t.Title))}");

#if BUG14
        TopN(tasks, t => t.Tags.ToArray(), 2); // string[] isn't IComparable<string[]>: which array is bigger?
#endif
    }
}
