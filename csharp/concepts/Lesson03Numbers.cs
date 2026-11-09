// Lesson 03: arithmetic, rounding, overflow, and turning text into a number.
// BUG03: adding 1 to the biggest int inside `checked`. It builds, then throws OverflowException.
// Without `checked`, C# wraps round silently, the way C does.

namespace Concepts;

public static class Lesson03Numbers
{
    public const string Title = "Numbers";

    /// <summary>Rounds halves to the even neighbour, like Python's round(): 2.5 -> 2, 3.5 -> 4.</summary>
    public static int RoundHalfEven(double value) => (int)Math.Round(value); // ToEven is Math.Round's default

    public static void Run()
    {
        Console.WriteLine($"7 / 2 = {7 / 2}, 7 % 2 = {7 % 2}, 7.0 / 2.0 = {7.0 / 2.0}"); // int / int drops the rest
        Console.WriteLine($"0.1 + 0.2 = {0.1 + 0.2}"); // double is a binary fraction: close, not exact
        Console.WriteLine($"0.1m + 0.2m = {0.1m + 0.2m}"); // decimal counts in tens: exact, for money

        // Math.Round sends halves to even, which is what Python does and what the tracker needs.
        Console.WriteLine($"Math.Round(2.5) = {Math.Round(2.5)}, Math.Round(3.5) = {Math.Round(3.5)}");
        Console.WriteLine($"AwayFromZero: {Math.Round(2.5, MidpointRounding.AwayFromZero)}");
        // Formatting rounds too, and not always the same way: F0 goes to even, the custom "0" goes up.
        // So the tracker rounds with Math.Round first and then prints a whole number.
        Console.WriteLine($"12.5 as F0 = {12.5:F0}, as \"0\" = {12.5.ToString("0")}, RoundHalfEven = {RoundHalfEven(12.5)}");

        // An int holds 32 bits. Plain arithmetic wraps when it overflows; `checked` throws instead.
        int biggest = int.MaxValue;
        Console.WriteLine($"int.MaxValue + 1 wraps to {unchecked(biggest + 1)}");
        Console.WriteLine($"(int)3.99 = {(int)3.99}"); // a cast to int drops the fraction

        // TryParse turns text into a number, or says it couldn't, without throwing.
        foreach (string text in new[] { "5", "five", "-3", " 7 " })
        {
            if (int.TryParse(text, out int n))
            {
                Console.WriteLine($"\"{text}\" -> {n}");
            }
            else
            {
                Console.WriteLine($"\"{text}\" isn't a whole number");
            }
        }

#if BUG03
        int big = int.MaxValue; // a variable: with a constant, the compiler would refuse to build
        Console.WriteLine(checked(big + 1)); // 2147483648 doesn't fit in an int
#endif
    }
}
