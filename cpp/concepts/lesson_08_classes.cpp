// Lesson 08: a class bundles data with the functions that use it, and keeps the data private.
// virtual lets UrgentTask change how a task prints; override asks the compiler to check that it
// really does replace something. operator<< teaches std::cout to print a Task.
// BUG=8: an override that doesn't match (const is missing). override turns that into an error.

#pragma once
#include "concepts.hpp"
#include "lesson_05_decisions.cpp"  // Status

class Task {
public:
    Task(std::string title, Status status, std::vector<std::string> tags)
        : title_{std::move(title)}, status_{status}, tags_{std::move(tags)} {}  // move: take, don't copy
    virtual ~Task() = default;        // a base class used through pointers needs a virtual destructor

    // const after the brackets: calling it never changes the task.
    bool done() const { return status_ == Status::Done; }
    const std::string& title() const { return title_; }
    const std::vector<std::string>& tags() const { return tags_; }

    virtual bool urgent() const { return false; }
    virtual std::string str() const { return std::format("[{}] {}", done() ? 'x' : ' ', title_); }

private:                              // only Task's own functions can touch these
    std::string title_;
    Status status_;
    std::vector<std::string> tags_;
};

class UrgentTask : public Task {      // an UrgentTask is a Task...
public:
    using Task::Task;                 // ...built the same way...
    bool urgent() const override { return true; }
#if BUG == 8
    std::string str() override { return Task::str() + "  !!"; }  // not const: a new function, not an override
#else
    std::string str() const override { return Task::str() + "  !!"; }  // ...that prints differently
#endif
};

// std::cout << task. It takes a Task&, so the virtual str() picks the real kind of task.
std::ostream& operator<<(std::ostream& out, const Task& task) { return out << task.str(); }

void lesson_08() {
    Task plain{"Buy groceries", Status::Done, {"home"}};
    UrgentTask urgent{"Finish quarterly report", Status::Todo, {"work", "urgent"}};
    std::cout << plain << '\n' << urgent << '\n';

    const Task& seen_as_task = urgent;  // a reference to the base still finds UrgentTask's str()
    std::println("through a Task&: {}  urgent()? {}", seen_as_task.str(), seen_as_task.urgent());

    Task sliced = urgent;               // a copy into a Task keeps only the Task part: "slicing"
    std::println("copied into a Task: {}  urgent()? {}", sliced.str(), sliced.urgent());
    std::println("so a list of mixed tasks holds pointers to them: lesson 09");
}
