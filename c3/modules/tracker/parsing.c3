// One line of text into a task: the only place that knows the file format.
module tracker::parsing;
import std::collections::list, tracker::models;

const char TAG_MARKER = '#';                           // marks a word as a tag: "#work"
const AsciiCharset STATUS_JUNK @private = ascii::@create_set("[] .");  // "[done.]" -> "done"
const AsciiCharset TAG_JUNK @private = ascii::@create_set(".,");       // "#work." -> "work"

excuse { NOT_A_TASK }

// @private: only this module can call it. C needed static and a separate .c file for that.
fn Status status_of(String word) @private
{
	foreach (status : Status::values) if (status.word.len && word.compare_to_ignore_case(status.word) == 0) return status;
	return OTHER;
}

// The next word of text at or after *i, splitting on any whitespace like Python's split().
fn String next_word(String text, sz* i) @private
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
