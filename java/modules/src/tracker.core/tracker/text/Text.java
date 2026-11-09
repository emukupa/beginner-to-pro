package tracker.text;

import java.util.List;
import java.util.regex.Pattern;

// Python's text rules, shared by the parser, the chart and the program.
public final class Text {
    private Text() {} // only static methods: nothing to make

    // Exactly what Python's str.split() and str.strip() treat as space.
    private static final String SPACE = "\\t\\n\\u000B\\f\\r\\u001C\\u001D\\u001E\\u001F \\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2028\\u2029\\u202F\\u205F\\u3000";
    private static final Pattern EDGE_SPACE = Pattern.compile("^[" + SPACE + "]+|[" + SPACE + "]+$");
    private static final Pattern RUN_OF_SPACE = Pattern.compile("[" + SPACE + "]+");

    public static String strip(String s) {
        return EDGE_SPACE.matcher(s).replaceAll("");
    }

    public static List<String> words(String s) {
        String stripped = strip(s);
        return stripped.isEmpty() ? List.of() : List.of(RUN_OF_SPACE.split(stripped));
    }

    // Width in code points, as Python's len() counts.
    public static int width(String s) {
        return s.codePointCount(0, s.length());
    }
}
