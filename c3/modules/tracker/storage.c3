// Reading and writing the tasks file. The only module that opens files.
module tracker::storage;
import std::io, std::collections::list, tracker::models, tracker::parsing;

// Adds every task in the file to tasks. Passes on the file's excuse (io::FILE_NOT_FOUND, ...).
fn void? load_tasks(String path, List{Task}* tasks, Allocator a)
{
	File f = file::open(path, "r")!;
	defer (void)f.close();
	while (true)
	{
		String? line = io::readline(a, &f);
		if (catch why = line)
		{
			if (why == io::EOF) return;
			return why~;
		}
		if (try task = parsing::parse_line(line, a)) tasks.push(task);   // lines that aren't tasks are skipped
	}
}

// "[todo] title" lines on the end of the file.
fn void append_titles(String path, String[] titles)
{
	File? f = file::open(path, "a");
	if (catch f) return;
	defer (void)f.close();
	foreach (title : titles) (void)io::fprintfn(&f, "[todo] %s", title);
}
