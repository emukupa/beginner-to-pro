// Lesson 14: compile time. C's preprocessor pastes text; C3's macros and $-code are part of the
// language, so they're type-checked and can't break precedence. const values, $assert and
// contracts are checked while compiling, and $if (with $feat) is how every BUG switch in these
// lessons works.

module lesson14;
import std::io;

const int CHART_WIDTH = 20;
const int DEFAULT_TOP = 3;
$assert CHART_WIDTH > 0 : "a chart needs room for its bars";
$assert DEFAULT_TOP >= 1 : "the fallback must itself be a valid answer";

// A macro works for any type. In C, #define MAX(a, b) ((a) > (b) ? (a) : (b)) evaluates one of
// its arguments twice; a C3 macro evaluates each argument once, like a function.
macro @max(a, b) => a > b ? a : b;

// #expr receives the expression itself, unevaluated: the macro decides when, and how often, to run it.
macro @twice(#expr)
{
	#expr;
	#expr;
}

fn void run()
{
	io::printfn("@max(3, 7) = %d, @max(2.5, 1.5) = %.1f: one macro, two types", @max(3, 7), @max(2.5, 1.5));
	int calls;
	@twice(calls++);
	io::printfn("@twice(calls++) ran it %d times", calls);
	io::printfn("CHART_WIDTH has the type %s and the value %d, both known while compiling", $Typeof(CHART_WIDTH)::name, CHART_WIDTH);
	$if $feat(BUG14):
		$assert CHART_WIDTH > 100 : "is the chart wide enough?";
	$endif
	io::printn("every $assert held, or this file wouldn't have compiled");
}
