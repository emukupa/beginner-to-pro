// Working with the list: adding, counting, ranking, summing up. No files, no printing.
using Tracker.Models;

namespace Tracker;

public static class TaskList
{
    public const int DefaultTop = 3;

    // Parses each title as a new "[todo]" task and adds it. Returns how many were added.
    public static int AddTasks(List<Models.Task> tasks, IEnumerable<string> titles)
    {
        int before = tasks.Count;
        tasks.AddRange(titles.Select(t => Parsing.ParseLine($"[todo] {t}")).OfType<Models.Task>());
        return tasks.Count - before;
    }

    // The first task whose title matches, ignoring case and extra spaces; null if there isn't one.
    public static Models.Task? FindTask(IEnumerable<Models.Task> tasks, string title)
    {
        string wanted = string.Join(' ', Text.Words(title)).ToLowerInvariant();
        return tasks.FirstOrDefault(t => t.Title.ToLowerInvariant() == wanted);
    }

    // Every tag with how many tasks carry it, in the order each tag first appears. A Dictionary
    // doesn't promise any order, so the List keeps it and the Dictionary finds each tag's place.
    public static List<TagCount> CountTags(IEnumerable<Models.Task> tasks, bool includeDone = true)
    {
        var counts = new List<TagCount>();
        var place = new Dictionary<string, int>();
        foreach (var task in tasks.Where(t => includeDone || !t.IsDone))
        {
            foreach (var tag in task.Tags)
            {
                if (place.TryGetValue(tag, out int i))
                {
                    counts[i] = counts[i] with { Count = counts[i].Count + 1 };
                }
                else
                {
                    place[tag] = counts.Count;
                    counts.Add(new TagCount(tag, 1));
                }
            }
        }
        return counts;
    }

    // The n items with the biggest key, biggest first, for any type. OrderByDescending is stable.
    public static List<T> TopN<T>(IEnumerable<T> items, int n, Func<T, int> key) where T : notnull =>
        items.OrderByDescending(key).Take(n).ToList();

    public static IReadOnlyList<TagCount> TopTags(List<Models.Task> tasks, int n, bool includeDone = true)
    {
        ArgumentOutOfRangeException.ThrowIfLessThan(n, 1); // Python's ValueError
        return TopN(CountTags(tasks, includeDone), n, c => c.Count);
    }

    // The numbers on the summary line: a record, so the caller can take it apart.
    public record Summary(int Total, int Done, double Percent, int Tags);

    public static Summary Summarize(IReadOnlyList<Models.Task> tasks)
    {
        int done = tasks.Count(t => t.IsDone);
        double percent = tasks.Count > 0 ? (double)done / tasks.Count * 100 : 0;
        // Math.Round's default is MidpointRounding.ToEven: Python's round().
        return new Summary(tasks.Count, done, Math.Round(percent), CountTags(tasks).Count);
    }
}
