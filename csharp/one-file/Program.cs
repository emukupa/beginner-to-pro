// The task tracker in one C# file. Same prompts, summary and chart as the Python version, byte for
// byte: contract/run.sh checks every one. Read top to bottom: main (top-level statements, so no
// class Program), then what a task is, parsing a line, the file, counting and ranking, the chart,
// and talking to the user.

using System.Text;
using System.Text.RegularExpressions;

Console.OutputEncoding = new UTF8Encoding(false); // UTF-8 for the █ bars, with no byte-order mark

string path = args.Length > 0 ? args[0] : Environment.GetEnvironmentVariable("TASKS_FILE") ?? "tasks.txt";

List<Task> tasks;
try
{
    tasks = Tracker.LoadTasks(path);
}
catch (Exception e) when (e is FileNotFoundException or DirectoryNotFoundException) // `when` filters by type
{
    Console.Error.WriteLine($"Couldn't find {path}");
    return 1;
}
catch (Exception e) when (e is IOException or UnauthorizedAccessException)
{
    Console.Error.WriteLine($"Couldn't read {path}");
    return 1;
}

var newTitles = new List<string>();
while (true)
{
    string title = Text.Strip(Input.Ask("New task (Enter to finish): "));
    if (title == "") break;
    if (title.StartsWith(Tracker.TagMarker))
    {
        Console.WriteLine("A task needs a title, not just tags.");
        continue;
    }
    newTitles.Add(title);
}
if (Tracker.AddTasks(tasks, newTitles) > 0)
{
    File.AppendAllText(path, string.Concat(newTitles.Select(t => $"[todo] {t}\n")), new UTF8Encoding(false));
}

IReadOnlyList<TagCount> pairs;
try
{
    string answer = Input.Ask("How many top tags? [3]: ");
    pairs = Tracker.TopTags(tasks, answer == "" ? Tracker.DefaultTop : Input.ParseWholeNumber(answer) ?? 0);
}
catch (ArgumentOutOfRangeException) // Python's ValueError
{
    Console.WriteLine("Need a whole number of at least 1 — using 3.");
    pairs = Tracker.TopTags(tasks, Tracker.DefaultTop);
}

int done = tasks.Count(t => t.IsDone);
double percent = tasks.Count > 0 ? (double)done / tasks.Count * 100 : 0;
int tagCount = Tracker.CountTags(tasks).Count;
// Math.Round's default is MidpointRounding.ToEven: Python's round(). (So is $"{x:F0}"; the custom
// format "0" is the one that sends halves up.)
Console.WriteLine($"\n{tasks.Count} tasks, {done} done ({Math.Round(percent)}%), {tagCount} tags");
foreach (var task in tasks.OfType<UrgentTask>().Where(t => !t.IsDone)) // OfType: only the urgent ones
{
    Console.WriteLine(task);
}

Console.WriteLine("\nTop tags");
Chart.Draw(pairs);
return 0;

// ---- What a task is ---------------------------------------------------------------------------

// A class, as in Python. Properties with `init` can be set once, when the task is made, then never.
class Task
{
    public required string Title { get; init; }
    public required string Status { get; init; }
    public required IReadOnlyList<string> Tags { get; init; }

    public bool IsDone => Status == "done";

    public override string ToString() => $"[{(IsDone ? "x" : " ")}] {Title}";
}

// C# has inheritance, so Python's UrgentTask(Task) stays a subclass. `override` replaces ToString.
class UrgentTask : Task
{
    public override string ToString() => base.ToString() + "  !!";
}

// A record: a small value with equality and a ToString written for it. Two items, a tag and a count.
record TagCount(string Tag, int Count);

// ---- Python's text rules ----------------------------------------------------------------------

static class Text
{
    // Exactly what Python's str.split() and str.strip() treat as space. char.IsWhiteSpace is close,
    // but misses \x1c-\x1f, which Python counts.
    const string Space = "\t\n\v\f\r\x1c\x1d\x1e\x1f \x85\xa0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u2028\u2029\u202f\u205f\u3000";

    public static string Strip(string s) => s.Trim(Space.ToCharArray());

    // string.Split() with no arguments splits at every single space; Python's split() at runs of it.
    public static string[] Words(string s) => s.Split(Space.ToCharArray(), StringSplitOptions.RemoveEmptyEntries);

    // Width in code points, as Python's len() counts: "█" is one, "é" is one.
    public static int Width(string s) => s.EnumerateRunes().Count();
}

// ---- Parsing, the file, counting and ranking --------------------------------------------------

static class Tracker
{
    public const string TagMarker = "#";
    public const int DefaultTop = 3;

    // "[done.] Call mom #family" -> a Task, or null if the line isn't a task. `Task?` says so, and
    // with nullable reference types on, the compiler makes every caller check.
    public static Task? ParseLine(string line)
    {
        string s = Text.Strip(line);
        if (!s.StartsWith('[')) return null;
        int close = s.IndexOf(']'); // Python's partition("]")
        string raw = close < 0 ? s : s[..close];
        string rest = close < 0 ? "" : s[(close + 1)..];
        string status = raw.Trim('[', ']', ' ', '.').ToLowerInvariant();
        string[] words = Text.Words(rest);
        var tags = words.Where(w => w.StartsWith(TagMarker))
                        .Select(w => w.TrimStart('#').Trim('.', ',').ToLowerInvariant())
                        .ToList();
        string title = string.Join(' ', words.Where(w => !w.StartsWith(TagMarker)));
        return tags.Contains("urgent")
            ? new UrgentTask { Title = title, Status = status, Tags = tags }
            : new Task { Title = title, Status = status, Tags = tags };
    }

    // Every task in the file; lines that aren't tasks are skipped. Lines end at \n, \r\n or \r, as
    // when Python reads a text file. Missing or unreadable files throw.
    public static List<Task> LoadTasks(string path) =>
        Regex.Split(File.ReadAllText(path), "\r\n|\r|\n")
             .Select(ParseLine)
             .OfType<Task>() // drops the nulls, and the compiler knows what's left isn't null
             .ToList();

    // Parses each title as a new "[todo]" task and adds it. Returns how many were added.
    public static int AddTasks(List<Task> tasks, IEnumerable<string> titles)
    {
        int before = tasks.Count;
        tasks.AddRange(titles.Select(t => ParseLine($"[todo] {t}")).OfType<Task>());
        return tasks.Count - before;
    }

    // Every tag with how many tasks carry it, in the order each tag first appears. A Dictionary
    // doesn't promise any order, so the List keeps it and the Dictionary finds each tag's place.
    public static List<TagCount> CountTags(IEnumerable<Task> tasks, bool includeDone = true)
    {
        var counts = new List<TagCount>();
        var place = new Dictionary<string, int>();
        foreach (var task in tasks.Where(t => includeDone || !t.IsDone))
        {
            foreach (var tag in task.Tags)
            {
                if (place.TryGetValue(tag, out int i))
                {
                    counts[i] = counts[i] with { Count = counts[i].Count + 1 }; // a changed copy of the record
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

    // The n items with the biggest key, biggest first, for any type. OrderByDescending is stable,
    // so ties keep their order.
    public static List<T> TopN<T>(IEnumerable<T> items, int n, Func<T, int> key) where T : notnull =>
        items.OrderByDescending(key).Take(n).ToList();

    public static IReadOnlyList<TagCount> TopTags(List<Task> tasks, int n, bool includeDone = true)
    {
        ArgumentOutOfRangeException.ThrowIfLessThan(n, 1); // Python's ValueError("n must be at least 1")
        return TopN(CountTags(tasks, includeDone), n, c => c.Count);
    }
}

// ---- The chart --------------------------------------------------------------------------------

static class Chart
{
    const int Width = 20; // the longest bar, in characters
    const char Bar = '█';

    public static void Draw(IReadOnlyList<TagCount> pairs)
    {
        // A list pattern: an empty list, or one whose first item we name.
        if (pairs is not [var first, ..])
        {
            Console.WriteLine("No tags yet.");
            return;
        }
        int labelWidth = pairs.Max(p => Text.Width(p.Tag));
        foreach (var (tag, count) in pairs) // a record takes itself apart
        {
            int blocks = (int)Math.Round((double)count / first.Count * Width); // to even, like Python
            string pad = new(' ', labelWidth - Text.Width(tag));
            Console.WriteLine($"{tag}{pad}  {new string(Bar, blocks)} {count}");
        }
    }
}

// ---- Talking to the user ----------------------------------------------------------------------

static class Input
{
    static readonly Stream Stdin = Console.OpenStandardInput();

    // Python's input(): shows the prompt, reads up to the next \n, and keeps anything else (a \r
    // too). Console.ReadLine would also end a line at a lone \r. An empty line at the end of input.
    public static string Ask(string prompt)
    {
        Console.Write(prompt);
        var bytes = new List<byte>();
        int b;
        while ((b = Stdin.ReadByte()) != -1 && b != '\n') bytes.Add((byte)b);
        return Encoding.UTF8.GetString(bytes.ToArray());
    }

    // Python's int(text): optional spaces, an optional sign, digits with single underscores between
    // them, optional spaces. int.Parse takes no underscores, so it's a regular expression. Capped.
    public static int? ParseWholeNumber(string text)
    {
        var match = Regex.Match(Text.Strip(text), @"^([+-]?)([0-9]+(?:_[0-9]+)*)$");
        if (!match.Success) return null;
        string digits = match.Groups[2].Value.Replace("_", "").TrimStart('0');
        int value = digits.Length > 9 ? int.MaxValue : digits == "" ? 0 : int.Parse(digits);
        return match.Groups[1].Value == "-" ? -value : value;
    }
}
