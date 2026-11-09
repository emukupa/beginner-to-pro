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
}
