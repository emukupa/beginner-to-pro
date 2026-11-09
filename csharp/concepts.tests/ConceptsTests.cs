// Each test checks one piece the lessons build, the same pieces the tracker will need.
// [TestMethod] marks a test; [DataRow] runs the same test once per row.

// The tests share nothing that changes, so they can run side by side.
[assembly: Parallelize(Scope = ExecutionScope.MethodLevel)]

namespace Concepts.Tests;

[TestClass]
public sealed class ConceptsTests
{
    [TestMethod]
    [DataRow(0.5, 0)]
    [DataRow(1.5, 2)]
    [DataRow(2.5, 2)]
    [DataRow(3.5, 4)]
    [DataRow(12.5, 12)]
    public void HalvesRoundToEven(double value, int expected) =>
        Assert.AreEqual(expected, Lesson03Numbers.RoundHalfEven(value));

    [TestMethod]
    [DataRow("[done]", "done")]
    [DataRow("[done.]", "done")]
    [DataRow("[DONE]", "done")]
    [DataRow("[ todo ]", "todo")]
    public void CleansStatus(string raw, string expected) =>
        Assert.AreEqual(expected, Lesson04Strings.CleanStatus(raw));

    [TestMethod]
    public void WordsSplitOnRunsOfWhitespace() =>
        CollectionAssert.AreEqual(new[] { "Call", "mom", "#family" }, Lesson04Strings.Words("  Call \t mom #family "));

    [TestMethod]
    public void BarsRoundToEven()
    {
        Assert.AreEqual(13, Lesson06Methods.Bar(2, 3).Length); // 13.33 -> 13
        Assert.AreEqual(7, Lesson06Methods.Bar(1, 3).Length); // 6.67 -> 7
        Assert.AreEqual(20, Lesson06Methods.Bar(3, 3).Length);
    }

    [TestMethod]
    public void ParsesStatusIntoTheEnum()
    {
        Assert.AreEqual(Status.Done, Lesson07Enums.ParseStatus("[done.]"));
        Assert.AreEqual(Status.Todo, Lesson07Enums.ParseStatus("[ todo ]"));
        Assert.AreEqual(Status.Other, Lesson07Enums.ParseStatus("[doing]"));
    }

    [TestMethod]
    public void ParsesALineWithMessyTags()
    {
        Task? task = Lesson10Nullable.ParseLine("[ todo ] Review pull request #work.");
        Assert.IsNotNull(task);
        Assert.AreEqual("Review pull request", task.Title);
        Assert.IsFalse(task.IsDone);
        CollectionAssert.AreEqual(new[] { "work" }, task.Tags.ToArray());
        Assert.AreEqual("[ ] Review pull request", task.ToString());
    }

    [TestMethod]
    public void UrgentTagMakesAnUrgentTask()
    {
        Task? task = Lesson10Nullable.ParseLine("[todo] Finish quarterly report #work #urgent");
        Assert.IsInstanceOfType<UrgentTask>(task);
        Assert.AreEqual("[ ] Finish quarterly report  !!", task.ToString());
    }

    [TestMethod]
    [DataRow("")]
    [DataRow("   ")]
    [DataRow("just a note")]
    public void LinesThatAreNotTasksGiveNull(string line) =>
        Assert.IsNull(Lesson10Nullable.ParseLine(line));

    [TestMethod]
    public void LoadsEveryTaskInTheFile()
    {
        List<Task> tasks = Lesson11Errors.LoadTasks(Lesson11Errors.TasksFile);
        Assert.HasCount(6, tasks);
        Assert.AreEqual(3, tasks.Count(t => t.IsDone));
    }

    [TestMethod]
    public void MissingFileThrows() =>
        Assert.ThrowsExactly<FileNotFoundException>(() => Lesson11Errors.LoadTasks("no-such-file.txt"));

    [TestMethod]
    [DataRow("0")]
    [DataRow("-2")]
    public void TopBelowOneIsRefused(string text) =>
        Assert.ThrowsExactly<ArgumentOutOfRangeException>(() => Lesson11Errors.ParseTop(text));

    [TestMethod]
    public void CountsKeepFirstSeenOrder()
    {
        List<Task> tasks = Lesson11Errors.LoadTasks(Lesson11Errors.TasksFile);
        List<TagCount> counts = Lesson12Collections.CountTags(tasks);
        CollectionAssert.AreEqual(new[] { "home", "work", "urgent", "family", "travel" }, counts.Select(c => c.Tag).ToArray());
        Assert.AreEqual(new TagCount("work", 3), counts[1]); // records compare by value
        CollectionAssert.AreEqual(counts, Lesson13Linq.CountTagsLinq(tasks));
    }

    [TestMethod]
    public void TopNKeepsTiesInFileOrder()
    {
        List<Task> tasks = Lesson11Errors.LoadTasks(Lesson11Errors.TasksFile);
        List<TagCount> top = Lesson14Generics.TopN(Lesson12Collections.CountTags(tasks), c => c.Count, 3);
        CollectionAssert.AreEqual(new[] { "work", "home", "urgent" }, top.Select(c => c.Tag).ToArray());
        CollectionAssert.AreEqual(top, Lesson13Linq.TopTags(tasks, 3));
    }
}
