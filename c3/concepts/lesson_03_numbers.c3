// Lesson 03: numbers. Integer division throws away the fraction, % gives the remainder, and
// doubles round in more than one way. The tracker's percentages must round halves to even, like
// Python, so 12.5% shows as 12.

module lesson03;
import std::io, std::math;

fn void run()
{
	io::printfn("7 / 2 = %d, 7 %% 2 = %d, -7 / 2 = %d", 7 / 2, 7 % 2, -7 / 2);
	io::printfn("7.0 / 2 = %.1f", 7.0 / 2);

	double half = 12.5;
	io::printfn("round(%.1f) = %.0f, roundeven(%.1f) = %.0f", half, math::round(half), half,
		math::roundeven(half));
	io::printfn("1 done of 8 is %.1f%%: the tracker shows %.0f%%", 100.0 / 8, math::roundeven(100.0 / 8));

	// Text to a number: to_int returns an optional int, written int?. It holds a number or an
	// excuse saying why there isn't one. ?? gives a fallback. Lesson 09 covers optionals properly.
	int three = "3".to_int() ?? -1;
	int five = "five".to_int() ?? -1;
	io::printfn("\"3\" -> %d, \"five\" -> %d (the fallback)", three, five);

	$if $feat(BUG03):
		int nothing = 7 / 0;                          // the compiler works this out, and refuses
	$endif
}
