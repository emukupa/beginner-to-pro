// Lesson 04: decisions and loops. The C shapes are all here, with two fixes: a switch case no
// longer falls into the next one by accident, and foreach walks any array or list.

module lesson04;
import std::io;

fn String describe(String status)
{
	switch (status)                                   // C3 can switch on strings
	{
		case "done":
			return "finished";
		case "todo":
		case "doing":                                 // an empty case shares the next one's body
			return "still open";
		default:
			return "unknown";
	}
}

fn void run()
{
	foreach (String s : { "done", "todo", "doing", "later" }) io::printfn("%-5s -> %s", s, describe(s));

	int[] counts = { 4, 2, 2 };
	foreach (i, c : counts) io::printfn("counts[%d] = %d", i, c);   // with the index
	foreach_r (c : counts) io::printf("%d ", c);                     // backwards
	io::printn();

	for (int i = 0; i < 3; i++) io::printf("for %d  ", i);
	io::printn();
	int n = 3;
	while (n > 0) n--;
	io::printfn("while counted down to %d", n);

	// break and continue work as in C. To leave an outer loop, give it a name after the keyword.
	foreach OUTER: (int a : { 1, 2, 3 })
	{
		foreach (int b : { 1, 2, 3 })
		{
			if (a * b == 4) break OUTER;
			io::printf("%dx%d ", a, b);
		}
	}
	io::printn("then stopped at 2x2");
}
