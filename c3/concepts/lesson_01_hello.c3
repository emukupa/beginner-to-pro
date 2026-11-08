// Lesson 01: a C3 program is made of modules. This file is the module lesson01; main.c3 imports it
// and calls lesson01::run(). Anything from another module is called through its module name.

module lesson01;
import std::io;

fn void run()
{
	io::printn("Hello from C3.");                     // printn: print, then a newline
	io::printfn("%s has %d lessons.", "This course", 14);  // printfn: format, then a newline
	io::printf("No newline here, ");                  // printf: format, no newline
	io::printn("so this finishes the line.");
	// C3 looks like C on purpose: same braces, same types, and it can call C directly. What it
	// changes is the parts of C that went wrong most often. Every lesson shows one.
	$if $feat(BUG01):
		printn("Where does printn come from?");       // functions from other modules need their prefix
	$endif
}
