// The bar chart. It writes to any TextWriter: the screen in the program, a StringWriter in a test.
using Tracker.Models;

namespace Tracker;

public static class Chart
{
    public const int Width = 20; // the longest bar, in characters
    const char Bar = '█';

    public static void Draw(TextWriter output, IReadOnlyList<TagCount> pairs, int width = Width)
    {
        if (pairs is not [var first, ..])
        {
            output.Write("No tags yet.\n");
            return;
        }
        int labelWidth = pairs.Max(p => Text.Width(p.Tag));
        foreach (var (tag, count) in pairs)
        {
            int blocks = (int)Math.Round((double)count / first.Count * width); // to even, like Python
            output.Write($"{tag}{new string(' ', labelWidth - Text.Width(tag))}  {new string(Bar, blocks)} {count}\n");
        }
    }
}
