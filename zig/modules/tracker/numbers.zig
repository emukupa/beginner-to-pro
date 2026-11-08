// Rounding the way Python does, for the chart and the summary.

// Python's round() for the same float: halves go to the even neighbour (12.5 -> 12, 13.5 -> 14).
// Zig's @round sends halves away from zero, so the tie is handled here.
pub fn roundHalfEven(x: f64) f64 {
    if (x - @trunc(x) == 0.5) return 2 * @round(x / 2);
    return @round(x);
}
