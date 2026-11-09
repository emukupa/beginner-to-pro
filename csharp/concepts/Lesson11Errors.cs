// Lesson 11: when something goes wrong, C# throws an exception. `catch` handles it, a `when` filter
// picks which ones, and `finally` always runs. A `using` declaration closes a file (or anything
// IDisposable) when the method or block ends, even if an exception is on its way out.
// BUG11: a catch for Exception placed before a narrower one, which could then never run.

namespace Concepts;

/// <summary>The tracker's own exception, carrying the one that caused it (InnerException).</summary>
public class TrackerException(string message, Exception? inner = null) : Exception(message, inner);

/// <summary>A file that deletes itself when disposed: `using` makes sure that happens.</summary>
public sealed class TempFile : IDisposable
{
    public string Path { get; } = System.IO.Path.GetTempFileName();

    public void Dispose()
    {
        File.Delete(Path);
        Console.WriteLine("  (temp file deleted)");
    }
}

public static class Lesson11Errors
{
    public const string Title = "Exceptions and files";

    /// <summary>tasks.txt, copied next to the program by the build, so any folder works.</summary>
    public static string TasksFile => Path.Combine(AppContext.BaseDirectory, "tasks.txt");

    /// <summary>Every task in the file, in file order. Lines that aren't tasks are skipped.</summary>
    public static List<Task> LoadTasks(string path)
    {
        List<Task> tasks = [];
        using StreamReader reader = new(path); // UTF-8; closed when this method ends, however it ends
        while (reader.ReadLine() is string line) // null at the end of the file stops the loop
        {
            if (Lesson10Nullable.ParseLine(line) is Task task)
            {
                tasks.Add(task);
            }
        }
        return tasks;
    }

    /// <summary>"How many top tags?": a whole number of at least 1, or an exception saying why not.</summary>
    public static int ParseTop(string text)
    {
        int n = int.Parse(text); // throws FormatException for "five"
        if (n < 1)
        {
            throw new ArgumentOutOfRangeException(nameof(text), n, "n must be at least 1");
        }
        return n;
    }

    public static void Run()
    {
        List<Task> tasks = LoadTasks(TasksFile);
        Console.WriteLine($"{tasks.Count} tasks loaded from tasks.txt");

        try
        {
            LoadTasks("missing.txt");
        }
        catch (IOException e) when (e is FileNotFoundException or DirectoryNotFoundException)
        {
            Console.WriteLine($"Couldn't find missing.txt ({e.GetType().Name})");
        }

        foreach (string text in new[] { "5", "0", "five" })
        {
            try
            {
                Console.WriteLine($"ParseTop(\"{text}\") = {ParseTop(text)}");
            }
            catch (Exception e) when (e is FormatException or ArgumentOutOfRangeException)
            {
                Console.WriteLine($"ParseTop(\"{text}\"): need a whole number of at least 1 ({e.GetType().Name})");
            }
            finally
            {
                Console.WriteLine("  finally runs either way");
            }
        }

        // Wrap a low-level exception in one that says what the program was doing.
        try
        {
            try
            {
                LoadTasks("missing.txt");
            }
            catch (FileNotFoundException e)
            {
                throw new TrackerException("no tasks file", e);
            }
        }
        catch (TrackerException e)
        {
            Console.WriteLine($"TrackerException: {e.Message}, caused by {e.InnerException?.GetType().Name}");
        }

        // Two using declarations: the writer closes at the end of its block, the temp file at the end
        // of the outer one, last made, first disposed.
        {
            using TempFile temp = new();
            {
                using StreamWriter writer = new(temp.Path);
                writer.WriteLine("[todo] Water plants #home");
            }
            Console.WriteLine($"read back from the temp file: {LoadTasks(temp.Path)[0]}");
        }

#if BUG11
        try
        {
            LoadTasks("missing.txt");
        }
        catch (Exception)
        {
            Console.WriteLine("something went wrong");
        }
        catch (FileNotFoundException) // Exception already caught everything
        {
            Console.WriteLine("no file");
        }
#endif
    }
}
