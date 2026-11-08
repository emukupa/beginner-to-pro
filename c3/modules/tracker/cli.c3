// The program the user talks to. The only module that reads input, prints to the screen, or exits.
//
// Everything the program allocates lives exactly as long as one run, so main runs inside one @pool
// and every module allocates with the tmem it's given: nothing is freed by hand, nothing can leak.
module tracker::cli;
import std::io, std::math, std::os::env, std::time::datetime, std::collections::list;
import tracker::models, tracker::parsing, tracker::storage, tracker::tasklist, tracker::chart;

const sz CHART_WIDTH = 20;                             // the longest bar, in characters
const long DEFAULT_TOP = 3;                            // top tags shown when the answer is empty or invalid
$assert DEFAULT_TOP >= 1 : "the fallback must itself be a valid answer";
$assert CHART_WIDTH > 0 : "a chart needs room for its bars";

excuse { NOT_A_NUMBER }

// Like Python's input(): shows the prompt, reads one line. An empty line at the end of input.
fn String ask(String prompt) @private
{
	io::print(prompt);
	(void)io::stdout().flush();
	return io::treadline() ?? "";
}

// Python's int(text): optional spaces, an optional sign, digits with single underscores between
// them, optional spaces. Anything else is not a whole number. Huge numbers are capped.
fn long? parse_whole_number(String text) @private
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
		if (catch why = storage::load_tasks(path, &tasks, tmem))
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
			if (title[0] == parsing::TAG_MARKER)
			{
				io::printn("A task needs a title, not just tags.");
				continue;
			}
			new_titles.push(title.tcopy());
		}
		String today = datetime::now().to_local().format(tmem, DATEONLY);
		if (tasklist::add_tasks(&tasks, new_titles.array_view(), today, tmem)) storage::append_titles(path, new_titles.array_view());

		String answer = ask("How many top tags? [3]: ");
		long n = answer.len ? parse_whole_number(answer) ?? 0 : DEFAULT_TOP;
		TagCount[]? asked = tasklist::top_tags(tasks.array_view(), n, true, tmem);
		if (catch asked) io::printn("Need a whole number of at least 1 — using 3.");
		TagCount[] pairs = asked ?? tasklist::top_tags(tasks.array_view(), DEFAULT_TOP, true, tmem)!!;  // DEFAULT_TOP is valid

		Summary s = tasklist::summarize(tasks.array_view(), tmem);
		io::printfn("\n%d tasks, %d done (%.0f%%), %d tags", s.total, s.done, math::roundeven(s.percent), s.tags);
		foreach (&t : tasks) if (t.kind == URGENT && !t.is_done()) io::printfn("%s", t);

		io::printn("\nTop tags");
		(void)chart::draw_chart(io::stdout(), pairs, CHART_WIDTH, "█");
	};
	return 0;
}
