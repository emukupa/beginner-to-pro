// Everything a lesson needs from the C++ standard library, in one place. Every lesson includes
// this, so each lesson file also makes sense on its own to clangd, not only inside main.cpp.
#pragma once

#include <algorithm>
#include <array>
#include <charconv>
#include <cmath>
#include <concepts>
#include <cstddef>
#include <expected>
#include <format>
#include <fstream>
#include <iostream>
#include <limits>
#include <map>
#include <memory>
#include <optional>
#include <print>
#include <ranges>
#include <span>
#include <stdexcept>
#include <string>
#include <string_view>
#include <unordered_map>
#include <utility>
#include <vector>

#ifndef BUG
#define BUG 0  // make NN BUG=1 sets it to the lesson's number, compiling that lesson's mistake in
#endif
