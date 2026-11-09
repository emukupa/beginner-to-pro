// Lesson 13: LINQ asks questions of any sequence: Where filters, Select changes each item, Count,
// Any and Sum add up, GroupBy gathers equal keys, OrderByDescending sorts (stably: ties keep their
// order) and Take keeps the first few. Queries are lazy: nothing runs until you loop over the result
// or call ToList, Count or the like.
// BUG13: putting a query straight into a List<Task> without ToList().

namespace Concepts;

public static class Lesson13Linq
{
    public const string Title = "LINQ";

    /// <summary>Lesson 12's CountTags in one query. GroupBy keeps keys in first-seen order.</summary>
    public static List<TagCount> CountTagsLinq(IEnumerable<Task> tasks) =>
        tasks.SelectMany(t => t.Tags)
             .GroupBy(tag => tag)
             .Select(group => new TagCount(group.Key, group.Count()))
             .ToList();

    /// <summary>The n most used tags. OrderByDescending is stable, so ties stay in file order.</summary>
    public static List<TagCount> TopTags(IEnumerable<Task> tasks, int n) =>
        CountTagsLinq(tasks).OrderByDescending(c => c.Count).Take(n).ToList();

    public static void Run()
    {
        List<Task> tasks = Lesson11Errors.LoadTasks(Lesson11Errors.TasksFile);
        Console.WriteLine($"{tasks.Count(t => t.IsDone)} done, any urgent: {tasks.Any(t => t is UrgentTask)}");
        Console.WriteLine($"still to do: {string.Join(", ", tasks.Where(t => !t.IsDone).Select(t => t.Title))}");
        Console.WriteLine($"letters in all titles: {tasks.Sum(t => t.Title.Length)}");
        Console.WriteLine($"urgent and open: {string.Join(", ", tasks.OfType<UrgentTask>().Where(t => !t.IsDone))}");
        Console.WriteLine($"distinct tags: {tasks.SelectMany(t => t.Tags).Distinct().Count()}");

        // Lazy: the query is only a recipe until something asks for its results, and each ask runs it again.
        int looked = 0;
        IEnumerable<Task> done = tasks.Where(t => { looked++; return t.IsDone; });
        Console.WriteLine($"after building the query, looked at {looked}");
        int first = done.Count();
        int second = done.Count();
        Console.WriteLine($"after counting twice ({first}, {second}), looked at {looked}");

        // Records compare by value, so SequenceEqual can check the two counts agree, item by item.
        Console.WriteLine($"CountTagsLinq matches CountTags: {CountTagsLinq(tasks).SequenceEqual(Lesson12Collections.CountTags(tasks))}");
        Console.WriteLine($"TopTags(4): {string.Join(", ", TopTags(tasks, 4).Select(c => $"{c.Tag} {c.Count}"))}");

        // The same query in query syntax, which reads like SQL. The compiler turns it into the calls above.
        var titles = from t in tasks where t.IsDone orderby t.Title select t.Title;
        Console.WriteLine($"done, by title: {string.Join(", ", titles)}");

#if BUG13
        List<Task> open = tasks.Where(t => !t.IsDone); // a query isn't a List until ToList() makes one
#endif
    }
}
