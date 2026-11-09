// Lesson 08: a class bundles data (properties) with behaviour (methods). `init` lets a property be
// set once, when the object is made; `required` says it must be. `virtual` lets a subclass replace a
// method and `override` says it does: Task and UrgentTask are the tracker's two kinds of task.
// BUG08: UrgentTask's ToString without `override`. It would hide Task's instead of replacing it.

namespace Concepts;

public class Task
{
    public required string Title { get; init; } // must be given when the task is made, then fixed
    public Status Status { get; init; } = Status.Todo;
    public IReadOnlyList<string> Tags { get; init; } = []; // read-only from outside: no Add, no Remove

    public bool IsDone => Status == Status.Done; // a computed property: worked out each time it's read

    // object.ToString is virtual, so every class can say how it prints.
    public override string ToString() => $"[{Lesson07Enums.Mark(Status)}] {Title}";
}

public class UrgentTask : Task
{
#if BUG08
    public string ToString() => base.ToString() + "  !!";
#else
    public override string ToString() => base.ToString() + "  !!"; // base: Task's version
#endif
}

public static class Lesson08Classes
{
    public const string Title = "Classes and inheritance";

    public static void Run()
    {
        // An object initializer sets the init properties. Leaving out Title won't build.
        Task groceries = new() { Title = "Buy groceries", Status = Status.Done, Tags = ["home"] };
        Task report = new UrgentTask { Title = "Finish quarterly report", Tags = ["work", "urgent"] };
        Console.WriteLine($"{groceries} (done: {groceries.IsDone})");

        // report's type is Task, but the object is an UrgentTask, so UrgentTask's ToString runs.
        List<Task> tasks = [groceries, report];
        foreach (Task task in tasks)
        {
            Console.WriteLine($"{task}   <- {task.GetType().Name}");
        }

        // `is` tests the type; with a name it also gives you the object as that type.
        // A property pattern { IsDone: false } tests its properties too.
        foreach (Task task in tasks)
        {
            if (task is UrgentTask { IsDone: false } urgent)
            {
                Console.WriteLine($"urgent and open: {urgent.Title}");
            }
        }

        // Classes compare by identity: two tasks with the same text are still two tasks.
        Task copy = new() { Title = "Buy groceries", Status = Status.Done, Tags = ["home"] };
        Console.WriteLine($"same text, same task? {copy == groceries}");
    }
}
