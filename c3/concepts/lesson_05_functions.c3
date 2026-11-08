// Lesson 05: functions. Default and named arguments, short functions with =>, and contracts:
// @require says what a caller must pass, @ensure what the function promises back. Contracts are
// checked while you develop (at compile time when the compiler can see the values) and cost
// nothing in a release build.

module lesson05;
import std::io;

<*
 Scales a count to a bar of at most width characters.
 @require biggest > 0 : "there must be at least one count"
 @require count <= biggest : "no count is bigger than the biggest"
 @ensure return <= width
*>
fn int bar_length(int count, int biggest, int width = 20) => count * width / biggest;

fn String plural(int n, String one, String many = "") => n == 1 ? one : many;

fn void run()
{
	io::printfn("4 of 4 -> %d blocks, 2 of 4 -> %d", bar_length(4, 4), bar_length(2, 4));
	io::printfn("named: %d", bar_length(count: 1, biggest: 4, width: 8));
	io::printfn("1 %s, 3 %s", plural(1, "task", "tasks"), plural(3, "task", "tasks"));

	// Arguments are copies, as in C: changing n here can't change the caller's variable.
	// Lesson 07 shows how a function changes something it was given.
	$if $feat(BUG05):
		io::printfn("%d", bar_length(5, 0));          // breaks @require biggest > 0
	$endif
}
