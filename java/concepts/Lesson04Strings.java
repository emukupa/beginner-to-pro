// Lesson 04: a String never changes. Every "change" (toLowerCase, strip, replace) makes a new
// String. Compare text with equals, never ==. length() counts UTF-16 units, which isn't always
// the number of characters you see.
// bug: title[0]. A String isn't an array; charAt(0) or codePointAt(0) is how you ask for a character.

import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Locale;

final class Lesson04Strings {
    static final String TITLE = "Strings";

    private Lesson04Strings() {}

    /** Python's text.strip(chars): drop any of these characters from both ends. Java has no such method. */
    static String stripChars(String text, String chars) {
        int start = 0;
        int end = text.length();
        while (start < end && chars.indexOf(text.charAt(start)) >= 0) {
            start++;
        }
        while (end > start && chars.indexOf(text.charAt(end - 1)) >= 0) {
            end--;
        }
        return text.substring(start, end);
    }

    /** "[ DONE. ]" -> "done". Lesson 08's Status.parse uses it on every status in the file. */
    static String cleanStatus(String text) {
        // Locale.ROOT: lower-case the same way on every computer (in Turkish, "I" lowers to "ı")
        return stripChars(text, "[] .").toLowerCase(Locale.ROOT);
    }

    static void run() {
        String title = "Call mom";
        String loud = title.toUpperCase(Locale.ROOT);
        System.out.println(title + " / " + loud + "  (title itself is unchanged)");

        String built = new StringBuilder("do").append("ne").toString(); // builds "done" at run time
        System.out.println("built == \"done\": " + (built == "done")
                + ", built.equals(\"done\"): " + built.equals("done"));

        String messy = "  done  "; //   is an em space, a Unicode space
        System.out.println("trim() -> \"" + messy.trim() + "\", strip() -> \"" + messy.strip() + "\"");
        // trim() only knows the old ASCII spaces; strip() knows Unicode's. Neither is exactly Python's.

        String line = "[done.] Call mom  #family";
        int close = line.indexOf(']');
        System.out.println("indexOf(']') = " + close + ", before: \"" + line.substring(0, close + 1)
                + "\", after: \"" + line.substring(close + 1) + "\"");
        String[] words = line.substring(close + 1).strip().split("\\s+"); // split takes a regex: \s+ is any run of spaces
        System.out.println("split -> " + Arrays.toString(words) + ", joined: " + String.join("_", words));
        System.out.println("startsWith(\"[\"): " + line.startsWith("[") + ", contains(\"#\"): " + line.contains("#"));

        for (String status : new String[] {"[done]", "[done.]", "[DONE]", "[ todo ]"}) {
            System.out.printf("cleanStatus(%-10s) -> %s%n", "\"" + status + "\"", cleanStatus(status));
        }

        String block = "█";
        String pin = "📌";
        System.out.println("\"█\": length " + block.length() + ", UTF-8 bytes "
                + block.getBytes(StandardCharsets.UTF_8).length);
        System.out.println("\"📌\": length " + pin.length() + ", code points " + pin.codePointCount(0, pin.length()));
        System.out.println("repeat: " + block.repeat(5) + ", charAt(0) of title: " + title.charAt(0));

        // A text block keeps line breaks as written, and strips the indent they all share.
        String usage = """
                Usage: tracker [file]
                  file  defaults to tasks.txt""";
        System.out.println(usage);
    }
}
