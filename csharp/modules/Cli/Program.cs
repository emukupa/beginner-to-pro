// The task tracker, split into projects: the Tracker.Core library holds every job, one file each, and
// this program is the only part that reads input, prints to the screen or sets the exit code.
//
//   dotnet build Cli -c Release -o build            build/tracker
//   dotnet test                                     the tests in Tracker.Tests
using System.Text;
using System.Text.RegularExpressions;
using Tracker;
using Tracker.Models;

Console.OutputEncoding = new UTF8Encoding(false);

if (args is [var name, .. var words] && Commands.Changes.ContainsKey(name)) return Commands.Change(name, words); // tracker done|undo "title"

string path = args.Length > 0 ? args[0] : Environment.GetEnvironmentVariable("TASKS_FILE") ?? "tasks.txt";

List<Tracker.Models.Task> tasks;
try
{
    tasks = Storage.LoadTasks(path);
}
catch (Exception e) when (e is FileNotFoundException or DirectoryNotFoundException)
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
    if (title.StartsWith(Parsing.TagMarker))
    {
        Console.WriteLine("A task needs a title, not just tags.");
        continue;
    }
    newTitles.Add(title);
}
if (TaskList.AddTasks(tasks, newTitles) > 0) Storage.AppendTitles(path, newTitles);

IReadOnlyList<TagCount> pairs;
try
{
    string answer = Input.Ask("How many top tags? [3]: ");
    pairs = TaskList.TopTags(tasks, answer == "" ? TaskList.DefaultTop : Input.ParseWholeNumber(answer) ?? 0);
}
catch (ArgumentOutOfRangeException)
{
    Console.WriteLine("Need a whole number of at least 1 — using 3.");
    pairs = TaskList.TopTags(tasks, TaskList.DefaultTop);
}

var (total, done, percent, tagCount) = TaskList.Summarize(tasks); // a record, taken apart
Console.WriteLine($"\n{total} tasks, {done} done ({percent}%), {tagCount} tags");
foreach (var task in tasks.OfType<UrgentTask>().Where(t => !t.IsDone))
{
    Console.WriteLine(task);
}

Console.WriteLine("\nTop tags");
Chart.Draw(Console.Out, pairs);
return 0;

// What a status command does: the status it sets, and what it prints. A record per command.
record Change(Status Sets, string Changed, string Already);

// tracker done|undo "title": sets one task's status. Returns the exit code.
static class Commands
{
    // Python's CHANGES dict: the command words are the keys.
    public static readonly Dictionary<string, Change> Changes = new()
    {
        ["done"] = new(Status.Done, "Done", "Already done"),
        ["undo"] = new(Status.Todo, "Undone", "Not done yet"),
    };

    public static int Change(string name, string[] words)
    {
        var (sets, changed, already) = Changes[name];
        string title = Text.Strip(string.Join(' ', words));
        if (title == "")
        {
            Console.Error.WriteLine($"Usage: {name} \"task title\"");
            return 2;
        }
        string path = Environment.GetEnvironmentVariable("TASKS_FILE") ?? "tasks.txt";
        List<Tracker.Models.Task> tasks;
        try
        {
            tasks = Storage.LoadTasks(path);
        }
        catch (Exception e) when (e is FileNotFoundException or DirectoryNotFoundException)
        {
            Console.Error.WriteLine($"Couldn't find {path}");
            return 1;
        }
        catch (Exception e) when (e is IOException or UnauthorizedAccessException)
        {
            Console.Error.WriteLine($"Couldn't read {path}");
            return 1;
        }
        if (TaskList.FindTask(tasks, title) is not { } task)
        {
            Console.Error.WriteLine($"No task called \"{title}\"");
            return 1;
        }
        if (task.Status == sets.Word())
        {
            Console.WriteLine($"{already}: {task.Title}");
            return 0;
        }
        try
        {
            Storage.SetStatus(path, task, sets);
        }
        catch (Exception e) when (e is IOException or UnauthorizedAccessException)
        {
            Console.Error.WriteLine($"Couldn't write {path}");
            return 1;
        }
        Console.WriteLine($"{changed}: {task.Title}");
        return 0;
    }
}

// Reading what the user types: only this program does that, so it lives here, not in the library.
static class Input
{
    static readonly Stream Stdin = Console.OpenStandardInput();

    // Python's input(): shows the prompt, reads up to the next \n. An empty line at the end of input.
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
