// Lesson 10: with nullable reference types on (<Nullable>enable</Nullable>), `string` can never be
// null and `string?` might be. The compiler follows every path and warns before you use a value that
// might be null, and here that warning is an error. ParseLine returns Task?: null for a line that
// isn't a task, the way Python's parse_line returns None.
// BUG10: using ParseLine's result without checking it for null.

namespace Concepts;

public static class Lesson10Nullable
{
    public const string Title = "Nullable references";

    /// <summary>"[done.] Call mom #family" -> a Task; a blank line or a note -> null.</summary>
    public static Task? ParseLine(string line, char marker = '#')
    {
        line = line.Trim();
        if (!line.StartsWith('['))
        {
            return null; // blank, or not a task
        }
        int close = line.IndexOf(']');
        string status = close < 0 ? line : line[..close]; // like Python's partition("]")
        string rest = close < 0 ? "" : line[(close + 1)..];

        List<string> tags = [];
        List<string> words = [];
        foreach (string word in Lesson04Strings.Words(rest))
        {
            if (word.StartsWith(marker))
            {
                tags.Add(word.TrimStart(marker).Trim('.', ',').ToLowerInvariant()); // "#work." -> "work"
            }
            else
            {
                words.Add(word);
            }
        }

        string title = string.Join(' ', words);
        Status parsed = Lesson07Enums.ParseStatus(status);
        return tags.Contains("urgent")
            ? new UrgentTask { Title = title, Status = parsed, Tags = tags }
            : new Task { Title = title, Status = parsed, Tags = tags };
    }

    public static void Run()
    {
        string? nickname = null;
        Console.WriteLine($"nickname?.Length = {nickname?.Length.ToString() ?? "null"}"); // ?. stops at null
        Console.WriteLine($"nickname ?? \"(none)\" = {nickname ?? "(none)"}"); // ?? gives a fallback
        nickname ??= "Ed"; // ??= assigns only if it's null
        Console.WriteLine($"after ??=: {nickname}, Length {nickname.Length}"); // now known not null

        foreach (string line in new[] { "[done] Buy groceries #home", "just a note", "", "[ todo ] Review pull request #work." })
        {
            Task? task = ParseLine(line);
            if (task is null)
            {
                Console.WriteLine($"\"{line}\" -> null");
                continue;
            }
            // Past the check, the compiler knows task isn't null, so no warning here.
            Console.WriteLine($"\"{line}\" -> {task}  tags: {string.Join(", ", task.Tags)}");
        }

        Console.WriteLine($"ParseLine(\"hello\")?.Title ?? \"(not a task)\" = {ParseLine("hello")?.Title ?? "(not a task)"}");

        // ReadLine returns string?: null means the input has ended. Console.ReadLine does the same
        // (press Ctrl+D), so a prompt loop must handle it. A StringReader stands in for the keyboard.
        StringReader input = new("3\n");
        string? first = input.ReadLine();
        string? second = input.ReadLine();
        Console.WriteLine($"first \"{first}\", second is null: {second is null}");

        // value! tells the compiler "trust me, not null". If you're wrong, it's a NullReferenceException
        // at run time, so the tracker never uses it.

#if BUG10
        Console.WriteLine(ParseLine("just a note").Title); // ParseLine might return null
#endif
    }
}
