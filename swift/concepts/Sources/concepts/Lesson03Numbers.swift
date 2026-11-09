// Lesson 03: numbers. Int division drops the fraction, there are no silent conversions between
// Int and Double, and overflow stops the program instead of wrapping (unless you ask with &+).
// Rounding has a trap: .rounded() sends halves away from zero, Python's round() sends them to the
// even neighbour. The tracker needs Python's way: .rounded(.toNearestOrEven).
// BUG03: dividing a Double by an Int. Swift makes you convert one of them yourself.

enum Lesson03Numbers {
    static let title = "Numbers"

    static func run() {
        print("7 / 2 = \(7 / 2), 7 % 2 = \(7 % 2), -7 / 2 = \(-7 / 2) (towards zero; Python says -4)")
        print("7.0 / 2 = \(7.0 / 2)") // a literal can be either; 7.0 makes both Doubles

        let done = 3
        let total = 6
        let share = Double(done) / Double(total) // convert on purpose: Double(...) makes a new value
        print("Double(done) / Double(total) = \(share)")
        print("Int(3.9) = \(Int(3.9)) (drops the fraction), Int(exactly: 3.5) = \(Int(exactly: 3.5) ?? -1) (nil, shown as -1)")

        // The rounding trap: same inputs, two rules.
        for x in [0.5, 1.5, 2.5] {
            print("\(x).rounded() = \(x.rounded()), .rounded(.toNearestOrEven) = \(x.rounded(.toNearestOrEven))")
        }
        print("Python: round(0.5) = 0, round(1.5) = 2, round(2.5) = 2 -> .toNearestOrEven matches")

        // Overflow: + checks and stops the program; &+ wraps on purpose; the Reporting version tells you.
        let small: UInt8 = 250
        print("small &+ 10 = \(small &+ 10) (wrapped)")
        let (sum, overflow) = small.addingReportingOverflow(10)
        print("addingReportingOverflow(10) = (\(sum), overflow: \(overflow))")

        // Text to number can fail, so Int("...") gives an optional Int (lesson 07). ?? supplies a default.
        print("Int(\"42\") ?? 0 = \(Int("42") ?? 0), Int(\"4 2\") ?? 0 = \(Int("4 2") ?? 0)")

        #if BUG03
        let average = share / total // Double / Int: which type should the answer be? Swift won't guess
        print(average)
        #endif
    }
}
