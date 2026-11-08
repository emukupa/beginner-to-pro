// Drawing (label, count) pairs as bars. Knows nothing about tasks, and doesn't decide where the
// chart goes: it draws to any OutStream, an interface that a file, standard out or a string can
// all implement. Return, don't print, the C3 way.
module tracker::chart;
import std::io, std::math, tracker::tasklist;

<*
 @require width > 0 : "a chart needs room for its bars"
*>
fn void? draw_chart(OutStream out, TagCount[] pairs, sz width, String bar)
{
	if (!pairs.len)
	{
		io::fprintn(out, "No tags yet.")!;
		return;
	}
	sz biggest = pairs[0].count;
	sz label_width;
	foreach (p : pairs) label_width = max(label_width, p.tag.utf8_codepoints());
	foreach (p : pairs)
	{
		sz blocks = (sz)math::roundeven((double)p.count / biggest * width);   // halves to even, like Python
		io::fprintf(out, "%s%*s  ", p.tag, (int)(label_width - p.tag.utf8_codepoints()), "")!;
		for (sz b = 0; b < blocks; b++) io::fprint(out, bar)!;
		io::fprintfn(out, " %d", p.count)!;
	}
}
