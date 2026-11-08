// What a task is. Includes nothing of ours: every other module builds on this one.
#pragma once
#include <format>
#include <memory>
#include <string>
#include <vector>

namespace tracker {

enum class Status : unsigned char { Todo, Done, Other };

class Task {
public:
    Task(std::string title, Status status, std::vector<std::string> tags)
        : title_{std::move(title)}, status_{status}, tags_{std::move(tags)} {}
    virtual ~Task() = default;  // deleted through a Task pointer, so the destructor is virtual

    const std::string& title() const { return title_; }
    const std::vector<std::string>& tags() const { return tags_; }
    Status status() const { return status_; }
    bool is_done() const { return status_ == Status::Done; }
    virtual bool urgent() const { return false; }
    virtual std::string str() const { return std::format("[{}] {}", is_done() ? 'x' : ' ', title_); }

    std::string created;  // "YYYY-MM-DD" for tasks added this run, else ""

private:
    std::string title_;
    Status status_;
    std::vector<std::string> tags_;
};

// Python's UrgentTask(Task): the same task, printed with "  !!" on the end.
class UrgentTask : public Task {
public:
    using Task::Task;
    bool urgent() const override { return true; }
    std::string str() const override { return Task::str() + "  !!"; }
};

using TaskList = std::vector<std::unique_ptr<Task>>;  // the list owns its tasks, of either kind

}  // namespace tracker
