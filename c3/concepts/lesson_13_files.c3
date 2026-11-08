// Lesson 13: files. file::open returns a File? like everything else that can fail, defer closes it
// on every way out, and readline reads one line at a time. With the earlier lessons this is a small
// tracker: load tasks.txt, then count, rank and chart its tags.

module lesson13;
import std::io, std::math, std::collections::list, lesson05, lesson08, lesson11, lesson12, lesson12::top;

// Every task in the file, allocated with a. An excuse if the file can't be opened.
fn List{Task}? load_tasks(String path, Allocator a)
{
	File f = file::open(path, "r")!;
	defer (void)f.close();                            // runs however we leave
	List{Task} tasks;
	tasks.init(a);
	while (true)
	{
		String? line = io::readline(a, &f);
		if (catch why = line)
		{
			if (why == io::EOF) break;
			return why~;
		}
		if (try task = lesson11::parse_task(line, a)) tasks.push(task);   // skip lines that aren't tasks
	}
	return tasks;
}

fn void run()
{
	@pool()
	{
		if (catch why = load_tasks("missing.txt", tmem)) io::printfn("missing.txt: %s", why);

		List{Task} tasks = load_tasks("tasks.txt", tmem) ?? {};
		int done;
		foreach (&t : tasks) if (t.is_done()) done++;
		io::printfn("%d tasks, %d done (%.0f%%)", tasks.len(), done,
			math::roundeven(tasks.len() ? 100.0 * done / tasks.len() : 0));
		foreach (&t : tasks) if (t.kind == URGENT && !t.is_done()) io::printfn("%s", t);

		List{TagCount} counts = lesson12::count_tags(tasks.array_view(), tmem);
		lesson12::rank(counts.array_view());
		int widest;
		foreach (c : counts) if (lesson08::width(c.tag) > widest) widest = (int)lesson08::width(c.tag);
		foreach (c : top::first{TagCount}(counts.array_view(), 3))
		{
			DString bar;
			bar.tinit();
			for (int i = 0; i < lesson05::bar_length(c.count, counts[0].count, 20); i++) bar.append("█");
			io::printfn("%-*s %s %d", widest, c.tag, bar.str_view(), c.count);
		}
	};
}
