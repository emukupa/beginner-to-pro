// Lesson 06: arrays and slices. A fixed array knows its size, and a slice is a pointer plus a length,
// so a function taking a slice always knows how many items it got. Every index is checked while
// you develop: going past the end stops the program instead of reading someone else's memory.

module lesson06;
import std::io;

fn int total(int[] counts)                            // a slice: any number of ints, with .len
{
	int sum;                                          // C3 zeroes local variables
	foreach (c : counts) sum += c;
	return sum;
}

fn void run()
{
	int[4] counts = { 4, 2, 2, 1 };
	io::printfn("%d items, total %d", counts.len, total(&counts));
	int[] middle = counts[1..2];                      // indexes 1 to 2, inclusive
	int[] first_three = counts[:3];                   // start at 0, take 3
	io::printfn("middle %s, first three %s", middle, first_three);

	foreach (&c : counts) *c *= 10;                   // &c: change the items in place
	io::printfn("times ten: %s", counts);

	int i = 4;
	$if $feat(BUG06):
		io::printfn("%d", counts[i]);                 // one past the end
	$endif
	io::printfn("counts[%d] would be one past the end", i);
}
