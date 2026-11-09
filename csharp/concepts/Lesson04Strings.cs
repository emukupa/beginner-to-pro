// Lesson 04: a string is a fixed run of UTF-16 chars. Every "change" (Trim, ToLower, Replace) makes a
// new string and leaves the old one as it was.
// BUG04: assigning to title[0]. A string's indexer can be read, never written.

using System.Text;

namespace Concepts;

public static class Lesson04Strings
{
    public const string Title = "Strings";

    /// <summary>"[done.]", "[DONE]", "[ todo ]" -> "done", "done", "todo": Python's strip("[] .").lower().</summary>
    public static string CleanStatus(string raw) => raw.Trim('[', ']', ' ', '.').ToLowerInvariant();

    /// <summary>Splits on runs of any whitespace, like Python's split() with no arguments.</summary>
    public static string[] Words(string text) => text.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries);

    /// <summary>How many characters a person sees (Unicode code points), not UTF-16 units.</summary>
    public static int TextWidth(string text) => text.EnumerateRunes().Count();

    /// <summary>Pads with spaces to `width` characters, counted the way TextWidth counts.</summary>
    public static string PadByWidth(string text, int width) =>
        text + new string(' ', Math.Max(0, width - TextWidth(text)));

    public static void Run()
    {
        string line = "  [done.] Call   mom #family  ";
        string trimmed = line.Trim(); // whitespace off both ends
        int close = trimmed.IndexOf(']'); // -1 if it isn't there
        string status = trimmed[..(close + 1)]; // a range: from the start up to (not including) close + 1
        string rest = trimmed[(close + 1)..]; // from close + 1 to the end
        Console.WriteLine($"status \"{status}\" -> CleanStatus \"{CleanStatus(status)}\", rest \"{rest}\"");
        foreach (string raw in new[] { "[done]", "[DONE]", "[ todo ]" })
        {
            Console.WriteLine($"  {raw,-9} -> {CleanStatus(raw)}");
        }

        // Split(' ') splits at every single space, so runs of spaces leave empty strings behind.
        Console.WriteLine($"Split(' ') gives {rest.Split(' ').Length} parts, Words gives {Words(rest).Length}: {string.Join("|", Words(rest))}");
        Console.WriteLine($"Join: \"{string.Join(" ", Words(rest))}\"");

        Console.WriteLine($"StartsWith('#'): {"#home".StartsWith('#')}, Contains: {"Review".Contains("view")}, Upper: {"todo".ToUpperInvariant()}");
        // == compares the text, not where it is in memory. For other rules, say which:
        Console.WriteLine($"\"done\" == \"DONE\": {"done" == "DONE"}, ignoring case: {string.Equals("done", "DONE", StringComparison.OrdinalIgnoreCase)}");

        // Length counts UTF-16 units. Most characters are one; an emoji is two.
        string smile = "🙂";
        Console.WriteLine($"\"café\".Length = {"café".Length}, \"{smile}\".Length = {smile.Length}, TextWidth = {TextWidth(smile)}, UTF-8 bytes = {Encoding.UTF8.GetByteCount(smile)}");
        Console.WriteLine($"[{PadByWidth("café", 6)}] [{PadByWidth(smile, 3)}]");

        // Verbatim strings (@"...") keep backslashes; raw strings (""" ... """) keep everything.
        string path = @"C:\tasks\tasks.txt";
        string example = """[todo] Say "hi" #home""";
        Console.WriteLine($"{path}  {example}");

#if BUG04
        string title = "buy groceries";
        title[0] = 'B'; // strings never change: make a new one instead
#endif
    }
}
