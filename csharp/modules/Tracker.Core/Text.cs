// Python's text rules, shared by the parser, the chart and the command line.
namespace Tracker;

public static class Text
{
    // Exactly what Python's str.split() and str.strip() treat as space. char.IsWhiteSpace is close,
    // but misses \x1c-\x1f, which Python counts.
    const string Space = "\t\n\v\f\r\x1c\x1d\x1e\x1f \x85\xa0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u2028\u2029\u202f\u205f\u3000";

    public static string Strip(string s) => s.Trim(Space.ToCharArray());

    // string.Split() with no arguments splits at every single space; Python's split() at runs of it.
    public static string[] Words(string s) => s.Split(Space.ToCharArray(), StringSplitOptions.RemoveEmptyEntries);

    // Width in code points, as Python's len() counts: "█" is one, "é" is one.
    public static int Width(string s) => s.EnumerateRunes().Count();
}
