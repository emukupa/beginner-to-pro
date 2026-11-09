// Turning one line of text into a task. No files, no printing: text in, a Task out.
using Tracker.Models;

namespace Tracker;

public static class Parsing
{
    public const string TagMarker = "#";

    // internal: only this library (and its tests) can call it. The program can't.
    internal static string StatusOf(string raw) => raw.Trim('[', ']', ' ', '.').ToLowerInvariant();

    // "[done.] Call mom #family" -> a Task, or null if the line isn't a task.
    public static Models.Task? ParseLine(string line)
    {
        string s = Text.Strip(line);
        if (!s.StartsWith('[')) return null;
        int close = s.IndexOf(']'); // Python's partition("]")
        string raw = close < 0 ? s : s[..close];
        string rest = close < 0 ? "" : s[(close + 1)..];
        string[] words = Text.Words(rest);
        var tags = words.Where(w => w.StartsWith(TagMarker))
                        .Select(w => w.TrimStart('#').Trim('.', ',').ToLowerInvariant())
                        .ToList();
        string title = string.Join(' ', words.Where(w => !w.StartsWith(TagMarker)));
        string status = StatusOf(raw);
        return tags.Contains("urgent")
            ? new UrgentTask { Title = title, Status = status, Tags = tags }
            : new Models.Task { Title = title, Status = status, Tags = tags };
    }
}
