// The task tracker in one C3 file. Same prompts, summary and chart as the Python version, byte for
// byte: contract/run.sh checks every one. Read top to bottom: settings, what a task is, parsing a
// line, the file, counting and ranking, the chart, then main, the only part that talks to the user.
//
// Who owns the memory? Everything the program allocates lives exactly as long as one run, so main
// runs inside one @pool and allocates with tmem: no free() anywhere, and nothing can leak.

module tracker;
import std::io, std::math, std::sort, std::os::env, std::time::datetime, std::collections::list;

// ---- Settings ----------------------------------------------------------------------------------

const sz CHART_WIDTH = 20;                             // the longest bar, in characters
const long DEFAULT_TOP = 3;                            // top tags shown when the answer is empty or invalid
const char TAG_MARKER = '#';                           // marks a word as a tag: "#work"
const String BAR = "█";
$assert DEFAULT_TOP >= 1 : "the fallback must itself be a valid answer";
$assert CHART_WIDTH > 0 : "a chart needs room for its bars";

const AsciiCharset STATUS_JUNK = ascii::@create_set("[] .");  // "[done.]" -> "done"
const AsciiCharset TAG_JUNK = ascii::@create_set(".,");       // "#work." -> "work"

excuse { NOT_A_TASK, NOT_A_NUMBER, NO_TOP_TAGS }

// ---- What a task is ----------------------------------------------------------------------------

// The status, cleaned and named the moment we read it. Each value carries its word, and the whole
// enum fits in one byte.
enum Status : char (String word)
{
	TODO { "todo" },
	DONE { "done" },
	OTHER { "" },
}

// C3 has no inheritance; Python's UrgentTask(Task) is a kind field.
enum Kind { PLAIN, URGENT }

struct Task (Printable)
{
	String title;
	List{String} tags;
	Status status;
	Kind kind;
	String created;                                    // "YYYY-MM-DD" for tasks added this run, else ""
}

fn bool Task.is_done(&self) => self.status == DONE;

// How a task prints with %s: "[ ] Title", and "  !!" on the end of an urgent one.
fn sz? Task.to_format(&self, Formatter* f) @dynamic
{
	return f.printf("[%s] %s%s", self.is_done() ? "x" : " ", self.title, self.kind == URGENT ? "  !!" : "");
}

// ---- Parsing one line --------------------------------------------------------------------------

fn Status status_of(String word)
{
	foreach (status : Status::values) if (status.word.len && word.compare_to_ignore_case(status.word) == 0) return status;
	return OTHER;
}

// The next word of text at or after *i, splitting on any whitespace like Python's split().
// An empty String when there are no more.
fn String next_word(String text, sz* i)
{
	while (*i < text.len && text[*i].is_space()) (*i)++;
	sz start = *i;
	while (*i < text.len && !text[*i].is_space()) (*i)++;
	return text[start:*i - start];
}

// "[done.] Call mom #family" -> a Task, or NOT_A_TASK. Everything kept is copied with a.
fn Task? parse_line(String line, Allocator a)
{
	String s = line.trim();
	if (!s.len || s[0] != '[') return NOT_A_TASK~;

	// Python's partition("]"): what's before the first ], and what's after it.
	sz close = s.index_of_char(']') ?? s.len;
	String status = s[:close].trim_charset(STATUS_JUNK);
	String rest = close < s.len ? s[close + 1..] : "";

	Task task = { .status = status_of(status), .kind = PLAIN };
	task.tags.init(a);
	DString title;
	title.init(a);
	sz i;
	for (String word = next_word(rest, &i); word.len; word = next_word(rest, &i))
	{
		if (word[0] == TAG_MARKER)
		{
			while (word.len && word[0] == TAG_MARKER) word = word[1..];   // lstrip("#")
			String tag = word.trim_charset(TAG_JUNK).to_lower_copy(a);
			if (tag == "urgent") task.kind = URGENT;
			task.tags.push(tag);
			continue;
		}
		if (title.len()) title.append(' ');
		title.append(word);
	}
	task.title = title.str_view();
	return task;
}

// ---- The file ----------------------------------------------------------------------------------

// Adds every task in the file to tasks. Passes on the file's excuse (io::FILE_NOT_FOUND, ...).
fn void? load_tasks(String path, List{Task}* tasks, Allocator a)
{
	File f = file::open(path, "r")!;
	defer (void)f.close();
	while (true)
	{
		String? line = io::readline(a, &f);
		if (catch why = line)
		{
			if (why == io::EOF) return;
			return why~;
		}
		if (try task = parse_line(line, a)) tasks.push(task);   // lines that aren't tasks are skipped
	}
}

// Parses each title as a new "[todo]" task and adds it. Returns how many were added.
fn sz add_tasks(List{Task}* tasks, String[] titles, String created, Allocator a)
{
	sz added;
	foreach (title : titles)
	{
		Task? task = parse_line(string::format(a, "[todo] %s", title), a);
		if (catch task) continue;
		task.created = created;
		tasks.push(task);
		added++;
	}
	return added;
}

fn void append_titles(String path, String[] titles)
{
	File? f = file::open(path, "a");
	if (catch f) return;
	defer (void)f.close();
	foreach (title : titles) (void)io::fprintfn(&f, "[todo] %s", title);
}

// ---- Counting and ranking ----------------------------------------------------------------------

struct TagCount
{
	String tag;                                        // borrowed from a task
	sz count;
}

// Every tag with how many tasks carry it, in the order each tag first appears.
fn List{TagCount} count_tags(Task[] tasks, bool include_done, Allocator a)
{
	List{TagCount} counts;
	counts.init(a);
	foreach (&task : tasks)
	{
		if (!include_done && task.is_done()) continue;
		foreach (tag : task.tags)
		{
			sz k;
			while (k < counts.len() && counts[k].tag != tag) k++;
			if (k == counts.len()) counts.push({ tag, 0 });
			counts[k].count++;
		}
	}
	return counts;
}

// The n most used tags, most first. mergesort is stable, so ties keep first-seen order.
// NO_TOP_TAGS when n < 1, Python's ValueError.
fn TagCount[]? top_tags(Task[] tasks, long n, bool include_done, Allocator a)
{
	if (n < 1) return NO_TOP_TAGS~;
	TagCount[] counts = count_tags(tasks, include_done, a).array_view();
	sort::mergesort(counts, fn int(TagCount x, TagCount y) => (int)(x.count < y.count) - (int)(x.count > y.count));
	return counts[:(sz)n < counts.len ? (sz)n : counts.len];
}

// ---- The chart ---------------------------------------------------------------------------------

<*
 @require width > 0 : "a chart needs room for its bars"
*>
fn void draw_chart(TagCount[] pairs, sz width, String bar)
{
	if (!pairs.len)
	{
		io::printn("No tags yet.");
		return;
	}
	sz biggest = pairs[0].count;
	sz label_width;
	foreach (p : pairs) label_width = max(label_width, p.tag.utf8_codepoints());
	foreach (p : pairs)
	{
		sz blocks = (sz)math::roundeven((double)p.count / biggest * width);   // halves to even, like Python
		io::printf("%s%*s  ", p.tag, (int)(label_width - p.tag.utf8_codepoints()), "");
		for (sz b = 0; b < blocks; b++) io::print(bar);
		io::printfn(" %d", p.count);
	}
}

// ---- Talking to the user -----------------------------------------------------------------------

// Like Python's input(): shows the prompt, reads one line. An empty line at the end of input.
fn String ask(String prompt)
{
	io::print(prompt);
	(void)io::stdout().flush();
	return io::treadline() ?? "";
}

// Python's int(text): optional spaces, an optional sign, digits with single underscores between
// them, optional spaces. Anything else is not a whole number. Huge numbers are capped.
fn long? parse_whole_number(String text)
{
	String s = text.trim();
	sz i;
	bool negative;
	if (i < s.len && (s[i] == '+' || s[i] == '-')) negative = s[i++] == '-';
	if (i == s.len || !s[i].is_digit()) return NOT_A_NUMBER~;
	long value;
	for (; i < s.len; i++)
	{
		if (s[i] == '_' && i + 1 < s.len && s[i + 1].is_digit() && s[i - 1].is_digit()) continue;
		if (!s[i].is_digit()) return NOT_A_NUMBER~;
		long digit = (long)(s[i] - (char)'0');
		value = value > (long::max - digit) / 10 ? long::max : value * 10 + digit;
	}
	return negative ? -value : value;
}

fn int main(String[] args)
{
	@pool()
	{
		String path = args.len > 1 ? args[1] : env::tget_var("TASKS_FILE") ?? "tasks.txt";

		List{Task} tasks;
		tasks.tinit();
		if (catch why = load_tasks(path, &tasks, tmem))
		{
			io::eprintfn(why == io::FILE_NOT_FOUND ? "Couldn't find %s" : "Couldn't read %s", path);
			return 1;
		}

		List{String} new_titles;
		new_titles.tinit();
		while (true)
		{
			String title = ask("New task (Enter to finish): ").trim();
			if (!title.len) break;
			if (title[0] == TAG_MARKER)
			{
				io::printn("A task needs a title, not just tags.");
				continue;
			}
			new_titles.push(title.tcopy());
		}
		String today = datetime::now().to_local().format(tmem, DATEONLY);
		if (add_tasks(&tasks, new_titles.array_view(), today, tmem)) append_titles(path, new_titles.array_view());

		String answer = ask("How many top tags? [3]: ");
		long n = answer.len ? parse_whole_number(answer) ?? 0 : DEFAULT_TOP;
		TagCount[]? asked = top_tags(tasks.array_view(), n, true, tmem);
		if (catch asked) io::printn("Need a whole number of at least 1 — using 3.");
		TagCount[] pairs = asked ?? top_tags(tasks.array_view(), DEFAULT_TOP, true, tmem)!!;   // DEFAULT_TOP is valid

		sz done;
		foreach (&t : tasks) if (t.is_done()) done++;
		sz all_tags = count_tags(tasks.array_view(), true, tmem).len();
		double percent = tasks.len() ? (double)done / tasks.len() * 100 : 0;
		io::printfn("\n%d tasks, %d done (%.0f%%), %d tags", tasks.len(), done, math::roundeven(percent), all_tags);
		foreach (&t : tasks) if (t.kind == URGENT && !t.is_done()) io::printfn("%s", t);

		io::printn("\nTop tags");
		draw_chart(pairs, CHART_WIDTH, BAR);
	};
	return 0;
}
