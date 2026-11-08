// Lesson 02: types and sizes. In C, an int is "at least 16 bits" and a long depends on the machine.
// In C3 every integer type has one fixed size everywhere, so the numbers below never change.

module lesson02;
import std::io;

fn void run()
{
	io::printfn("char %d, short %d, int %d, long %d, int128 %d bytes",
		char::size, short::size, int::size, long::size, int128::size);
	io::printfn("sz %d bytes: the type for sizes and indexes, like C's size_t", sz::size);
	io::printfn("double %d bytes, bool %d byte", double::size, bool::size);

	// char is an unsigned byte (0..255); ichar is the signed one. Text is made of chars.
	char letter = 'A';
	io::printfn("'A' is the byte %d", letter);

	// Overflow is defined in C3: it wraps around. In C, signed overflow is undefined behaviour.
	int biggest = int::max;
	int wrapped = biggest + 1;
	io::printfn("int::max is %d, and one more wraps to %d", biggest, wrapped);

	// Widening is automatic. Narrowing, where a value might not fit, needs you to say so.
	long big = 5_000_000_000;                         // underscores make long numbers readable
	int fits = (int)(big / 1_000_000);
	io::printfn("%d million fits in an int once you cast it", fits);
	$if $feat(BUG02):
		int small = big;                              // a long doesn't fit in an int
	$endif
}
