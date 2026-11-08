// Lesson 11: structs, enums and methods. An enum can carry values of its own (here, the word for
// each status), methods are functions written Type.name(&self), and a struct that implements
// Printable can be printed with %s. One struct can include another inline: C3's answer to the
// inheritance C doesn't have.

module lesson11;
import std::io, std::collections::list, lesson08, lesson09;

enum Status : char (String word)                     // one byte, and each value has a word
{
	TODO { "todo" },
	DONE { "done" },
	OTHER { "other" },
}

enum Kind { PLAIN, URGENT }

const AsciiCharset TAG_JUNK = ascii::@create_set("#.,");  // stripped from "#work." -> "work"

struct Task (Printable)
{
	String title;
	Status status;
	Kind kind;
	List{String} tags;
}

fn bool Task.is_done(&self) => self.status == DONE;

// "[x] Title", and "  !!" on the end of an urgent one: how Task prints with %s.
fn sz? Task.to_format(&self, Formatter* f) @dynamic
{
	return f.printf("[%s] %s%s", self.is_done() ? "x" : " ", self.title, self.kind == URGENT ? "  !!" : "");
}

// "[done.] Call mom #family" -> a Task, or an excuse. Everything it keeps is copied with the
// allocator you pass, so the caller decides how long the task lives.
fn Task? parse_task(String line, Allocator a)
{
	String s = line.trim();
	if (!s.starts_with("[")) return lesson09::NOT_A_TASK~;
	sz close = s.index_of_char(']')!;
	String status = lesson08::clean_status(s[:close + 1]);
	Task task = {
		.status = lesson08::same_word(status, "done") ? DONE : lesson08::same_word(status, "todo") ? TODO : OTHER,
	};
	task.tags.init(a);
	DString title;
	title.init(a);
	@pool()
	{
		foreach (word : s[close + 1..].tsplit(" "))
		{
			if (!word.len) continue;                  // two spaces in a row
			if (word[0] == '#')
			{
				String tag = word.trim_charset(TAG_JUNK).to_lower_copy(a);
				if (tag == "urgent") task.kind = URGENT;
				task.tags.push(tag);
				continue;
			}
			if (title.len()) title.append(' ');
			title.append(word);
		}
	};
	task.title = title.str_view();
	return task;
}

struct Labelled                                       // inline: a Labelled *is* a Task, plus a label
{
	inline Task task;
	String label;
}

fn void run()
{
	@pool()
	{
		foreach (String line : { "[done.] Call mom #family", "[ todo ] Finish report #work #URGENT", "notes" })
		{
			Task? t = parse_task(line, tmem);
			if (catch why = t)
			{
				io::printfn("%s: %s", line, why);
				continue;
			}
			io::printfn("%s   status %s (%d byte), tags %s", t, t.status.word, Status::size, t.tags);
		}
		Labelled l = { .task = parse_task("[todo] Ship it #work", tmem)!!, .label = "big" };
		io::printfn("inline: l.title is \"%s\" and l prints as its task: %s", l.title, l.task);
	};
}
