// What a task is. Imports nothing of ours: every other module builds on this one.
module tracker::models;
import std::io, std::collections::list;

// The status, cleaned and named the moment we read it. Each value carries its word.
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
