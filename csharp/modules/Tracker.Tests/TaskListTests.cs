using Tracker;

namespace Tracker.Tests;

[TestClass]
public class TaskListTests
{
    static List<Models.Task> Load(params string[] lines) => lines.Select(Parsing.ParseLine).OfType<Models.Task>().ToList();

    [TestMethod]
    public void TiesKeepFirstSeenOrder()
    {
        var tasks = Load("[todo] a #work #home", "[todo] b #home #work", "[todo] c #play");
        CollectionAssert.AreEqual(new[] { "work", "home", "play" }, TaskList.TopTags(tasks, 3).Select(c => c.Tag).ToArray());
    }

    [TestMethod]
    public void ZeroIsRefused() => Assert.ThrowsExactly<ArgumentOutOfRangeException>(() => TaskList.TopTags([], 0));

    [TestMethod]
    public void HalvesRoundToEven()
    {
        var tasks = Load(["[done] a", .. Enumerable.Range(0, 7).Select(i => $"[todo] t{i}")]);
        Assert.AreEqual(12, TaskList.Summarize(tasks).Percent); // 12.5 -> 12, like Python's round()
    }

    [TestMethod]
    public void ChartDrawsIntoAStringWriter()
    {
        var output = new StringWriter();
        Chart.Draw(output, [new("home", 2), new("work", 1)], 4);
        Assert.AreEqual("home  ████ 2\nwork  ██ 1\n", output.ToString());
    }

    [TestMethod]
    public void FindsAMessyTitle()
    {
        var tasks = Load("[todo] Review pull request #work");
        Assert.AreEqual("Review pull request", TaskList.FindTask(tasks, "  review PULL   request ")?.Title);
        Assert.IsNull(TaskList.FindTask(tasks, "Walk dog"));
    }
}
