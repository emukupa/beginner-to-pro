using Tracker;
using Tracker.Models;

namespace Tracker.Tests;

[TestClass]
public class ParsingTests
{
    [TestMethod]
    public void ReadsStatusTitleAndTags()
    {
        var task = Parsing.ParseLine("[DONE.] Call mom #Family #urgent,");
        Assert.IsInstanceOfType<UrgentTask>(task);
        Assert.AreEqual("done", task.Status);
        Assert.AreEqual("Call mom", task.Title);
        CollectionAssert.AreEqual(new[] { "family", "urgent" }, task.Tags.ToArray());
    }

    // StatusOf is internal, and InternalsVisibleTo lets this project call it.
    [TestMethod]
    public void KeepsAnUnknownStatus() => Assert.AreEqual("later", Parsing.StatusOf("[ later ]"));

    [TestMethod]
    public void ALineWithoutABracketIsNotATask() => Assert.IsNull(Parsing.ParseLine("Buy milk #home"));
}
