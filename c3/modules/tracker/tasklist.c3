// The list of tasks: adding, counting, ranking. No printing, no files.
module tracker::tasklist;
import std::sort, std::collections::list, tracker::models, tracker::parsing;

excuse { NO_TOP_TAGS }

struct TagCount
{
	String tag;                                        // borrowed from a task in the list
	sz count;
}

// Parses each title as a new "[todo]" task and adds it. Returns how many were added.
fn sz add_tasks(List{Task}* tasks, String[] titles, String created, Allocator a)
{
	sz added;
	foreach (title : titles)
	{
		Task? task = parsing::parse_line(string::format(a, "[todo] %s", title), a);
		if (catch task) continue;
		task.created = created;
		tasks.push(task);
		added++;
	}
	return added;
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

// The comparator for mergesort: more first.
fn int most_first(TagCount x, TagCount y) @private => (int)(x.count < y.count) - (int)(x.count > y.count);

// The n most used tags, most first; mergesort is stable, so ties keep first-seen order.
// NO_TOP_TAGS when n < 1, Python's ValueError.
fn TagCount[]? top_tags(Task[] tasks, long n, bool include_done, Allocator a)
{
	if (n < 1) return NO_TOP_TAGS~;
	TagCount[] counts = count_tags(tasks, include_done, a).array_view();
	sort::mergesort(counts, &most_first);
	return counts[:(sz)n < counts.len ? (sz)n : counts.len];
}

struct Summary
{
	sz total, done, tags;
	double percent;
}

fn Summary summarize(Task[] tasks, Allocator a)
{
	Summary s = { .total = tasks.len };
	foreach (&t : tasks) if (t.is_done()) s.done++;
	s.tags = count_tags(tasks, true, a).len();
	s.percent = s.total ? (double)s.done / s.total * 100 : 0;
	return s;
}
