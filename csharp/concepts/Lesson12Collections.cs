// Lesson 12: List<T> is a list that grows, Dictionary<TKey, TValue> finds a value by key, and
// HashSet<T> keeps one of each. Every index is checked: reading past the end throws instead of
// reading whatever memory is there.
// BUG12: reading tasks[tasks.Count], one past the end. It builds, then throws when it runs.

namespace Concepts;

public static class Lesson12Collections
{
    public const string Title = "Collections";

    /// <summary>Each tag and how many tasks have it, in the order tags first appear in the file.
    /// The List keeps that order; the Dictionary finds a tag's place in the List.</summary>
    public static List<TagCount> CountTags(IEnumerable<Task> tasks)
    {
        List<TagCount> counts = [];
        Dictionary<string, int> place = []; // tag -> its index in counts
        foreach (Task task in tasks)
        {
            foreach (string tag in task.Tags)
            {
                if (place.TryGetValue(tag, out int i))
                {
                    counts[i] = counts[i] with { Count = counts[i].Count + 1 }; // records don't change: replace
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

    public static void Run()
    {
        List<Task> tasks = Lesson11Errors.LoadTasks(Lesson11Errors.TasksFile);
        tasks.Add(new Task { Title = "Water plants" });
        tasks.RemoveAt(tasks.Count - 1);
        Console.WriteLine($"{tasks.Count} tasks; first: {tasks[0]}; last: {tasks[^1]}"); // ^1: one from the end

        foreach (Task task in tasks.GetRange(0, 2)) // a copy of part of the list
        {
            Console.WriteLine($"  {task}");
        }

        Dictionary<string, int> byTag = [];
        foreach (Task task in tasks)
        {
            foreach (string tag in task.Tags)
            {
                byTag[tag] = byTag.GetValueOrDefault(tag) + 1; // 0 if it isn't there yet
            }
        }
        // byTag["gym"] would throw KeyNotFoundException; TryGetValue asks instead.
        bool hasGym = byTag.TryGetValue("gym", out int gym);
        Console.WriteLine($"byTag[\"work\"] = {byTag["work"]}, TryGetValue(\"gym\") = {hasGym}, {gym}");

        // A Dictionary often lists keys in the order they went in, but nothing promises it: remove
        // one and the next key added takes its old slot. Ties must keep file order, so CountTags
        // keeps the order in a List.
        Dictionary<string, int> order = new() { ["a"] = 1, ["b"] = 2, ["c"] = 3 };
        order.Remove("a");
        order["d"] = 4;
        Console.WriteLine($"added a b c, removed a, added d: {string.Join(" ", order.Keys)}");

        HashSet<string> distinct = [];
        foreach (Task task in tasks)
        {
            distinct.UnionWith(task.Tags);
        }
        Console.WriteLine($"{distinct.Count} distinct tags");
        Console.WriteLine($"CountTags: {string.Join(", ", CountTags(tasks))}");

#if BUG12
        Console.WriteLine(tasks[tasks.Count]); // indexes run 0 to Count - 1: this is one too far
#endif
    }
}
