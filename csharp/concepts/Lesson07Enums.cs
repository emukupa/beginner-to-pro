// Lesson 07: an enum is a type with a fixed set of named values. A switch expression over one has to
// handle every value, or the compiler warns, and warnings are errors here. Patterns can be combined
// with `or`.
// BUG07: a switch expression that forgets Status.Other.

namespace Concepts;

/// <summary>A task's cleaned status. Anything that isn't done or todo is Other.</summary>
public enum Status
{
    Todo,
    Done,
    Other,
}

public static class Lesson07Enums
{
    public const string Title = "Enums and switch expressions";

    /// <summary>"[DONE]" -> Done, "[ todo ]" -> Todo, "[doing]" -> Other.</summary>
    public static Status ParseStatus(string raw) => Lesson04Strings.CleanStatus(raw) switch
    {
        "done" => Status.Done,
        "todo" => Status.Todo,
        _ => Status.Other,
    };

    /// <summary>The mark inside [ ] when a task is printed: x for done, a space for anything else.</summary>
    public static char Mark(Status status) => status switch
    {
        Status.Done => 'x',
        Status.Todo or Status.Other => ' ',
    };

#if BUG07
    static string Label(Status status) => status switch
    {
        Status.Done => "done",
        Status.Todo => "to do",
    }; // Status.Other has nowhere to go
#endif

    public static void Run()
    {
        foreach (string raw in new[] { "[done]", "[DONE]", "[ todo ]", "[doing]" })
        {
            Status status = ParseStatus(raw);
            Console.WriteLine($"{raw,-9} -> {status,-5} [{Mark(status)}]");
        }

        // Underneath, an enum is a number: Todo is 0, Done 1, Other 2.
        Console.WriteLine($"(int)Status.Done = {(int)Status.Done}, all: {string.Join(", ", Enum.GetValues<Status>())}");

        // Enum.TryParse reads names, but numbers too, even ones that aren't members.
        // That's why the tracker writes its own ParseStatus instead.
        bool named = Enum.TryParse("done", ignoreCase: true, out Status fromName);
        bool numbered = Enum.TryParse("42", out Status fromNumber);
        Console.WriteLine($"TryParse(\"done\") = {named}, {fromName}; TryParse(\"42\") = {numbered}, {fromNumber}, defined: {Enum.IsDefined(fromNumber)}");
    }
}
