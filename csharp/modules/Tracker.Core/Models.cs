// What a task is. Every other file uses these; this one uses none of ours.
namespace Tracker.Models;

// public: visible to any project that references this library. Without it, a type is internal.
public class Task
{
    public required string Title { get; init; }
    public required string Status { get; init; }
    public required IReadOnlyList<string> Tags { get; init; }

    public bool IsDone => Status == "done";

    public override string ToString() => $"[{(IsDone ? "x" : " ")}] {Title}";
}

// Python's UrgentTask(Task): C# has inheritance, and `override` replaces ToString.
public class UrgentTask : Task
{
    public override string ToString() => base.ToString() + "  !!";
}

// The statuses a command can set. A task read from the file keeps whatever word it had, as a string.
public enum Status { Todo, Done }

public static class StatusWords
{
    // An extension method: status.Word() reads as if Status had it. The switch expression must
    // cover every member: add one to the enum and the build stops here (CS8509).
    public static string Word(this Status status) => status switch
    {
        Status.Todo => "todo",
        Status.Done => "done",
    };
}

// A record: a tag and how many tasks carry it.
public record TagCount(string Tag, int Count);
