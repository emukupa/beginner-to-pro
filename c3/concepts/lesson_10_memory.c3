// Lesson 10: memory. C3 still has the heap and free(), but every allocation goes through an
// allocator you name: mem (the heap, freed by you) or tmem (temporary, freed all at once when its
// @pool ends). defer runs a line when the scope ends, however it ends, so the free sits right
// next to the allocation it undoes.

module lesson10;
import std::io, std::core::mem::allocator;

fn void run()
{
	String kept = "Call mom".copy(mem);               // on the heap: ours until we free it
	defer kept.free(mem);                             // runs at the end of run(), not here
	io::printfn("copied \"%s\" onto the heap", kept);

	@pool()
	{
		String shout = "call mom".to_upper_tcopy();   // temp: no free needed
		io::printfn("temp copy \"%s\", freed when the pool ends", shout);
	};

	// A tracking allocator wraps another one and remembers every allocation, so it can tell
	// you what was never freed. Tests use one to prove there are no leaks.
	TrackingAllocator tracker;
	tracker.init(mem);
	defer tracker.free();
	String a = "work".copy(&tracker);
	String b = "home".copy(&tracker);
	a.free(&tracker);
	$if !$feat(BUG10):
		b.free(&tracker);                             // BUG10 forgets this one
	$endif
	io::printfn("leaks? %s (%d bytes still allocated)", tracker.has_leaks(), tracker.allocated());
}
