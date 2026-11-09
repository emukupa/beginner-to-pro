// The tasks file: the only file that opens files.
using System.Text;
using System.Text.RegularExpressions;

namespace Tracker;

public static class Storage
{
    // Every task in the file; lines that aren't tasks are skipped. Lines end at \n, \r\n or \r, as
    // when Python reads a text file. Missing or unreadable files throw.
    public static List<Models.Task> LoadTasks(string path) =>
        Regex.Split(File.ReadAllText(path), "\r\n|\r|\n")
             .Select(Parsing.ParseLine)
             .OfType<Models.Task>()
             .ToList();

    // "[todo] title" lines on the end of the file.
    public static void AppendTitles(string path, IEnumerable<string> titles) =>
        File.AppendAllText(path, string.Concat(titles.Select(t => $"[todo] {t}\n")), new UTF8Encoding(false));

    // True if this line holds the task: the same title and status after parsing.
    static bool Holds(string line, Models.Task task) =>
        Parsing.ParseLine(line) is { } found && found.Title == task.Title && found.Status == task.Status;

    // Rewrites the line holding this task as [done], leaving every other byte of the file alone.
    public static void MarkDone(string path, Models.Task task)
    {
        // Each line keeps its own ending (\n, \r\n or \r), as Python's readlines() does with newline="".
        var lines = Regex.Matches(File.ReadAllText(path), @"[^\r\n]*(?:\r\n|\r|\n)|[^\r\n]+$")
                         .Select(m => m.Value).ToList();
        int at = lines.FindIndex(line => Holds(line, task));
        if (at >= 0)
        {
            string line = lines[at];
            int open = line.IndexOf('['), close = line.IndexOf(']', open);
            lines[at] = $"{line[..open]}[done]{line[(close + 1)..]}"; // spaces before, title and ending after
        }

        using var temp = new TempFile(path); // disposed at the end of this method, however it ends
        if (!OperatingSystem.IsWindows()) File.SetUnixFileMode(temp.Path, File.GetUnixFileMode(path)); // keep the old permissions
        temp.Stream.Write(new UTF8Encoding(false).GetBytes(string.Concat(lines)));
        temp.Replace(path);
    }

    // A new file beside another, deleted when it's disposed unless it replaced the other. `using`
    // calls Dispose when the block ends: normally, or because something threw.
    sealed class TempFile : IDisposable
    {
        public string Path { get; }
        public FileStream Stream { get; }
        bool kept;

        // FileMode.CreateNew fails if the file exists, so a random name can't be anyone else's file.
        public TempFile(string beside)
        {
            Path = $"{beside}.{System.IO.Path.GetRandomFileName()}";
            Stream = new FileStream(Path, FileMode.CreateNew, FileAccess.Write);
        }

        // On the disk first, then moved over the target: readers see the old file or the new one.
        public void Replace(string target)
        {
            Stream.Flush(flushToDisk: true);
            Stream.Dispose();
            File.Move(Path, target, overwrite: true);
            kept = true;
        }

        public void Dispose()
        {
            Stream.Dispose();
            if (!kept) File.Delete(Path); // never leave the half-made file behind
        }
    }
}
