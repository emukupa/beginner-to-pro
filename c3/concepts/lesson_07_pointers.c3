// Lesson 07: pointers. C3 keeps C's pointers: &x is where x lives, *p is what's there. You need
// them less, because slices carry their length and methods take &self. Following a null pointer
// stops the program with a clear message instead of crashing somewhere later.

module lesson07;
import std::io;

fn void add_one(int* n) => (*n)++;                     // changes the caller's variable

fn int* find(int[] items, int wanted)
{
	foreach (&item : items) if (*item == wanted) return item;
	return null;                                      // nothing found
}

fn void run()
{
	int count = 1;
	add_one(&count);
	io::printfn("after add_one(&count): %d", count);

	int[] counts = { 4, 2, 7 };
	int* seven = find(counts, 7);
	if (seven) *seven = 70;
	io::printfn("found 7 and changed it through the pointer: %s", counts);

	int* missing = find(counts, 99);
	io::printfn("99 isn't there, so find returned %s", missing ? "a pointer" : "null");
	$if $feat(BUG07):
		io::printfn("%d", *missing);                  // following null
	$endif
}
