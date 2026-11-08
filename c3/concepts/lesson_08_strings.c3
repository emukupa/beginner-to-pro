// Lesson 08: strings. A String is a slice of chars: a pointer and a length, not a zero-terminated
// array. So trimming or taking part of a string makes no copy and can't run off the end. You copy
// only when you need to keep the text, and then you say which allocator owns it (lesson 10).

module lesson08;
import std::io;

// The characters to strip from a status: a set of ASCII bytes, built while compiling.
const AsciiCharset STATUS_JUNK = ascii::@create_set("[] .");

// "[DONE.]" -> "DONE": strip brackets, spaces and dots from both ends. A view of the same bytes.
fn String clean_status(String raw) => raw.trim_charset(STATUS_JUNK);

// Same letters, ignoring case: "DONE" and "done".
fn bool same_word(String a, String b) => a.compare_to_ignore_case(b) == 0;

// Characters on screen, not bytes: "█" is three bytes of UTF-8 but one character.
fn sz width(String s) => s.utf8_codepoints();

fn void run()
{
	String line = "  [done.] Call mom #family  ";
	String s = line.trim();
	sz close = s.index_of_char(']') ?? 0;             // an optional again: there might be no ']'
	String status = clean_status(s[:close + 1]);
	String rest = s[close + 1..].trim();
	io::printfn("status \"%s\", rest \"%s\"", status, rest);
	io::printfn("same word as \"DONE\"? %s", same_word(status, "DONE"));

	@pool()                                           // everything made with the temp allocator here
	{                                                 // is freed when this block ends
		foreach (word : rest.tsplit(" "))
		{
			if (word.starts_with("#")) io::printfn("tag \"%s\"", word[1..].to_lower_tcopy());
		}
		io::printfn("split on \" \" keeps empty pieces: %d parts in \"a  b\"", "a  b".tsplit(" ").len);
		DString out;                                  // a string that grows, like a list of chars
		out.tinit();
		out.append("Call");
		out.append(' ');
		out.append("mom");
		io::printfn("built \"%s\" (%d bytes)", out.str_view(), out.len());
	};
	io::printfn("\"█\" is %d bytes but %d character wide", "█".len, width("█"));
}
