package tracker.chart;

import java.io.PrintStream;
import java.util.List;
import tracker.models.TagCount;
import tracker.text.Text;

// The bar chart. It prints to any PrintStream: the screen in the program, a buffer in a test.
public final class Chart {
    private Chart() {}

    public static final int WIDTH = 20; // the longest bar, in characters

    public static void draw(PrintStream out, List<TagCount> pairs, int width) {
        if (pairs.isEmpty()) {
            out.print("No tags yet.\n");
            return;
        }
        double biggest = pairs.getFirst().count();
        int labelWidth = pairs.stream().mapToInt(p -> Text.width(p.tag())).max().orElse(0);
        for (TagCount p : pairs) {
            int blocks = (int) Math.rint(p.count() / biggest * width); // halves to even, like Python
            out.print(p.tag() + " ".repeat(labelWidth - Text.width(p.tag())) + "  " + "█".repeat(blocks) + " " + p.count() + "\n");
        }
    }
}
