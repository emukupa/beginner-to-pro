// Lesson 09: a record is a class made for values. From one line, the compiler writes a constructor,
// init-only properties, value equality (== compares the contents), ToString and Deconstruct.
// TagCount, a tag and how many tasks have it, is one.
// BUG09: changing a record's property after it's made. Its properties are init-only.

namespace Concepts;

public record TagCount(string Tag, int Count);

public static class Lesson09Records
{
    public const string Title = "Records";

    public static void Run()
    {
        TagCount work = new("work", 3);
        Console.WriteLine(work); // the ToString the compiler wrote
        Console.WriteLine($"equal to a new (\"work\", 3)? {work == new TagCount("work", 3)}"); // True: same contents

        // `with` makes a changed copy; the original stays as it was.
        TagCount more = work with { Count = 4 };
        Console.WriteLine($"{more}, and work is still {work.Count}");

        var (tag, count) = work; // deconstruct
        Console.WriteLine($"tag {tag}, count {count}");

        // Value equality makes records good keys: the set keeps one of each value.
        HashSet<TagCount> seen = [work, new("work", 3), new("home", 2)];
        Console.WriteLine($"{seen.Count} distinct values in the set");

#if BUG09
        work.Count = 4; // records don't change: make a copy with `with`
#endif
    }
}
