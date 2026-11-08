// C3 concepts, one lesson per file. Each file is its own module (lesson01 ... lesson14); this one
// imports them all and keeps them in a table of function pointers, so it can run any of them.
//
//   make            build/concepts, every lesson     make 07         just lesson 7
//   make 07 BUG=1   lesson 7 with its mistake compiled in (-D BUG07), to watch C3 catch it

module concepts;
import std::io;
import lesson01, lesson02, lesson03, lesson04, lesson05, lesson06, lesson07;
import lesson08, lesson09, lesson10, lesson11, lesson12, lesson13, lesson14;

alias LessonFn = fn void();                           // the type of a pointer to a lesson's run()

struct Lesson
{
	String title;
	LessonFn run;
}

const Lesson[] LESSONS = {
	{ "Hello", &lesson01::run }, { "Types and sizes", &lesson02::run }, { "Numbers", &lesson03::run },
	{ "Decisions and loops", &lesson04::run }, { "Functions and contracts", &lesson05::run },
	{ "Arrays and slices", &lesson06::run }, { "Pointers", &lesson07::run }, { "Strings", &lesson08::run },
	{ "Optionals and excuses", &lesson09::run }, { "Memory and allocators", &lesson10::run },
	{ "Structs, enums and methods", &lesson11::run }, { "Lists, maps and generics", &lesson12::run },
	{ "Files", &lesson13::run }, { "Compile time", &lesson14::run },
};

fn void show(sz i)
{
	io::printfn("\n=== %02d %s ===", i + 1, LESSONS[i].title);
	LESSONS[i].run();
}

fn int main(String[] args)
{
	if (args.len == 1)
	{
		foreach (i, lesson : LESSONS) show(i);
		return 0;
	}
	foreach (arg : args[1..])
	{
		int n = arg.to_int() ?? 0;                    // not a number counts as no such lesson
		if (n < 1 || n > LESSONS.len)
		{
			io::eprintfn("No lesson %s: pick 1 to %d.", arg, LESSONS.len);
			return 1;
		}
		show((sz)n - 1);
	}
	return 0;
}
