// Lesson 09: every object has one owner, and the owner's end is the object's end (RAII). No new
// and delete by hand: std::unique_ptr owns a heap object and frees it for you.
// BUG=9: using a unique_ptr after moving out of it. It's empty now; UBSan catches the call.

#pragma once
#include "concepts.hpp"
#include "lesson_08_classes.cpp"    // Task, UrgentTask, operator<<

// A class that says when it's made and when it's cleaned up. Files, locks and memory all work
// like this in C++: the destructor runs when the owner goes away, on every path out.
class Noisy {
public:
    explicit Noisy(std::string name) : name_{std::move(name)} { std::println("  open {}", name_); }
    ~Noisy() { std::println("  close {}", name_); }
    Noisy(const Noisy&) = delete;               // one owner: no copies
    Noisy& operator=(const Noisy&) = delete;

private:
    std::string name_;
};

void lesson_09() {
    std::println("a block:");
    {
        Noisy outer{"outer"};
        Noisy inner{"inner"};
        std::println("  end of the block");
    }                                           // closed here, newest first, without asking

    auto task = std::make_unique<UrgentTask>("Fix login bug", Status::Done, std::vector<std::string>{"work"});
    std::println("unique_ptr: {} (the size of one pointer: {} bytes)", task->str(), sizeof task);

    std::vector<std::unique_ptr<Task>> tasks;   // owns its tasks, of either kind
    tasks.push_back(std::make_unique<Task>("Call mom", Status::Done, std::vector<std::string>{"family"}));
    tasks.push_back(std::move(task));           // move: the vector is the owner now
    std::println("after the move, task is {}", task == nullptr ? "empty" : "still full");
    for (const auto& t : tasks) std::cout << "  " << *t << '\n';  // virtual str() through the pointer

    // shared_ptr counts its owners and frees on the last one. That costs a count on every copy and
    // hides who's in charge. The task list is the one owner here, so unique_ptr says it exactly.
    auto shared = std::make_shared<int>(5);
    auto another = shared;
    std::println("a shared_ptr with {} owners ({} seen from the other): for when ownership really is shared",
                 shared.use_count(), another.use_count());
#if BUG == 9
    std::println("{}", task->str());            // task was moved from: it holds nullptr
#endif
}
