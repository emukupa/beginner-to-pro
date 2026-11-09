// C# concepts, one lesson per file. Each lesson is a static class with a Title and a Run(); the
// table below lists them, and later lessons call what earlier ones built
// (Lesson04Strings.CleanStatus, Lesson11Errors.LoadTasks).
//
//   dotnet run                    every lesson, in order
//   dotnet run -- 7               just lesson 7 (or several: dotnet run -- 4 7)
//   dotnet run -p:Bug=7 -- 7      lesson 7 with its bug compiled in, to watch the compiler catch it
//
// This file has no class and no Main: these are "top-level statements". The compiler wraps them in
// a Main for you, and `args` is the command line.

using Concepts;

// The table of lessons: a title and the method to run. Action is "a method that takes nothing and
// returns nothing", so Lesson01Hello.Run fits.
(string Title, Action Run)[] lessons =
[
    (Lesson01Hello.Title, Lesson01Hello.Run),
    (Lesson02Values.Title, Lesson02Values.Run),
    (Lesson03Numbers.Title, Lesson03Numbers.Run),
    (Lesson04Strings.Title, Lesson04Strings.Run),
    (Lesson05Control.Title, Lesson05Control.Run),
    (Lesson06Methods.Title, Lesson06Methods.Run),
    (Lesson07Enums.Title, Lesson07Enums.Run),
    (Lesson08Classes.Title, Lesson08Classes.Run),
    (Lesson09Records.Title, Lesson09Records.Run),
    (Lesson10Nullable.Title, Lesson10Nullable.Run),
    (Lesson11Errors.Title, Lesson11Errors.Run),
    (Lesson12Collections.Title, Lesson12Collections.Run),
    (Lesson13Linq.Title, Lesson13Linq.Run),
    (Lesson14Generics.Title, Lesson14Generics.Run),
];

void RunLesson(int number)
{
    var (title, run) = lessons[number - 1];
    Console.WriteLine($"\n=== {number:D2} {title} ===");
    run();
}

if (args.Length == 0)
{
    for (int n = 1; n <= lessons.Length; n++)
    {
        RunLesson(n);
    }
    return 0;
}

foreach (string arg in args)
{
    if (int.TryParse(arg, out int n) && n >= 1 && n <= lessons.Length)
    {
        RunLesson(n);
    }
    else
    {
        Console.Error.WriteLine($"No lesson {arg}");
        return 1; // the exit code: anything but 0 tells the shell it failed
    }
}
return 0;
