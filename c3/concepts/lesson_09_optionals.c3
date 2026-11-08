// Lesson 09: errors as optionals. A function that can fail returns T?: either a T, or an excuse
// saying why not. C made you return a bool and write the result through a pointer, and nothing
// stopped you ignoring the bool. Here you can't use the value until you've dealt with the excuse.

module lesson09;
import std::io;

excuse { NOT_A_TASK, NO_TITLE }                      // this module's reasons for failing

// The title of "[todo] Buy milk", or an excuse.
fn String? title_of(String line)
{
	String s = line.trim();
	if (!s.starts_with("[")) return NOT_A_TASK~;      // ~ makes an excuse into a returned failure
	sz close = s.index_of_char(']')!;                 // ! passes index_of_char's excuse up to our caller
	String title = s[close + 1..].trim();
	if (!title.len) return NO_TITLE~;
	return title;
}

// How many lines are tasks. The first bad line stops it, and its excuse becomes ours.
fn int? count_tasks(String[] lines)
{
	int n;
	foreach (line : lines)
	{
		title_of(line)!;                              // rethrow if it failed, else ignore the title
		n++;
	}
	return n;
}

fn void run()
{
	foreach (String line : { "[todo] Buy milk", "Buy milk", "[done]", "[todo Buy milk" })
	{
		String? title = title_of(line);
		if (catch why = title)                        // the failure path, and why
		{
			io::printfn("%-16s -> %s", line, why);
			continue;
		}
		io::printfn("%-16s -> \"%s\"", line, title);  // after the catch, title is a plain String
	}
	io::printfn("?? gives a fallback: \"%s\"", title_of("nope") ?? "(untitled)");
	if (try n = count_tasks({ "[todo] a", "[done] b" })) io::printfn("try: %d tasks", n);
	if (catch why = count_tasks({ "[todo] a", "oops" })) io::printfn("count_tasks passed on %s", why);

	$if $feat(BUG09):
		String forgot = title_of("nope");             // using an optional as if it can't fail
	$endif
}
