// Lesson 12: lists, maps and generic modules. List{Task} is a growable array that works for any
// type: the standard library's list is a generic module, and so is the small one below. A
// HashMap counts fast but forgets the order things arrived in, and tied tags must keep that order,
// so the tracker counts into a list instead.

module lesson12::top <Type>;                         // a generic module: Type is filled in by its user

<*
 The first n items, or all of them if there are fewer.
 @require n >= 1 : "ask for at least one"
*>
fn Type[] first(Type[] items, sz n) => items[:n < items.len ? n : items.len];

module lesson12;
import std::io, std::sort, std::collections::list, std::collections::map, lesson11, lesson12::top;

struct TagCount
{
	String tag;                                       // borrowed from a task
	int count;
}

// Every tag with how many tasks carry it, in the order each tag first appears.
fn List{TagCount} count_tags(Task[] tasks, Allocator a)
{
	List{TagCount} counts;
	counts.init(a);
	foreach (&task : tasks)
	{
		foreach (tag : task.tags)
		{
			sz i;
			while (i < counts.len() && counts[i].tag != tag) i++;
			if (i == counts.len()) counts.push({ tag, 0 });
			counts[i].count++;
		}
	}
	return counts;
}

// Most first. mergesort is stable: equal counts keep their order, so ties stay in first-seen order.
fn void rank(TagCount[] counts) => sort::mergesort(counts, fn int(TagCount x, TagCount y) => y.count - x.count);

fn void run()
{
	@pool()
	{
		List{Task} tasks;
		tasks.tinit();
		foreach (String line : { "[done] Groceries #home", "[todo] Call mom #family",
			"[todo] Report #work #urgent", "[todo] Fix bug #work", "[done] Taxes #urgent #home" })
		{
			tasks.push(lesson11::parse_task(line, tmem)!!);   // !! : we know these all parse
		}
		List{TagCount} counts = count_tags(tasks.array_view(), tmem);
		io::printf("first seen:");
		foreach (c : counts) io::printf(" %s=%d", c.tag, c.count);
		rank(counts.array_view());
		io::printf("\nranked:    ");
		foreach (c : counts) io::printf(" %s=%d", c.tag, c.count);
		io::printf("\ntop 2:     ");
		foreach (c : top::first{TagCount}(counts.array_view(), 2)) io::printf(" %s", c.tag);
		io::printn();

		HashMap{String, int} by_tag;
		by_tag.tinit();
		foreach (c : counts) by_tag[c.tag] = c.count;
		io::printfn("a HashMap finds work=%d at once, but hands its keys back as %s", by_tag["work"]!!, by_tag.tkeys());
	};
}
