// Reading and writing the tasks file. The only module that opens files.
module tracker::storage;
import std::io, std::collections::list, libc, tracker::models, tracker::parsing;

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

// C's own functions, declared here and called directly. C3 links with the C library already.
extern fn CInt mkstemp(ZString template) @private;
extern fn CInt fsync(CInt fd) @private;
extern fn CInt fchmod(CInt fd, Mode_t mode) @private;

excuse { WRITE_FAILED }

// True if this line holds the task: the same title and status after parsing.
fn bool holds(String line, Task* task) @private
{
	Task? found = parsing::parse_line(line, tmem);
	return @ok(found) && found!!.title == task.title && found!!.status == task.status;
}

<*
 Rewrites the line holding this task as [todo] or [done], leaving every other byte of the file
 alone, then replaces the file safely (write_safely). The old file is untouched if anything fails.
 @require status != OTHER : "only todo and done have one way to be written"
*>
fn void? set_status(String path, Task* task, Status status)
{
	@pool()
	{
		char[] data = file::load_temp(path)!;          // every byte, line endings and all
		DString out;
		out.tinit(data.len + 8);
		bool changed;
		for (sz start = 0; start < data.len;)
		{
			sz end = start;
			while (end < data.len && data[end] != '\n') end++;
			if (end < data.len) end++;                    // keep the line's own ending
			String line = (String)data[start:end - start];
			start = end;
			sz open = line.index_of_char('[') ?? 0;
			sz close = line.index_of_char_from(']', open) ?? 0;
			if (changed || !close || !holds(line, task))
			{
				out.append(line);
				continue;
			}
			out.append(line[:open]);                      // any spaces before the bracket
			out.append("[");
			out.append(status.word);                      // the word each Status carries
			out.append("]");
			out.append(line[close + 1..]);                // the title, tags and line ending
			changed = true;
		}
		write_safely(path, out.str_view())!;
	};
}

// Writes text to a new file beside path, puts it on the disk, then renames it over path. A rename
// is atomic: anyone reading sees the old file or the new one, never half of each.
fn void? write_safely(String path, String text) @private
{
	ZString temp = string::tformat("%s.XXXXXX", path).zstr_tcopy();
	CInt fd = mkstemp(temp);                          // a new file nobody else is using
	if (fd == -1) return WRITE_FAILED~;
	defer libc::close(fd);
	defer catch libc::remove(temp);                   // only if we leave with an excuse
	Stat st;
	if (libc::stat(path.zstr_tcopy(), &st) == 0) fchmod(fd, st.st_mode & 0o7777);   // keep its permissions
	for (sz done = 0; done < text.len;)
	{
		sz n = libc::write(fd, &text[done], (usz)(text.len - done));
		if (n <= 0) return WRITE_FAILED~;
		done += n;
	}
	if (fsync(fd) != 0 || libc::rename(temp, path.zstr_tcopy()) != 0) return WRITE_FAILED~;
}
