// The bar chart. It writes through the function it's given: print in the program, an array in a test.

public let chartWidth = 20 // the longest bar, in characters

public func drawChart(_ pairs: [TagCount], width: Int = chartWidth, print write: (String) -> Void = { print($0) }) {
    guard let first = pairs.first else {
        write("No tags yet.")
        return
    }
    let labelWidth = pairs.map(\.tag.width).max() ?? 0
    for pair in pairs {
        let blocks = Int((Double(pair.count) / Double(first.count) * Double(width)).rounded(.toNearestOrEven))
        write("\(pair.tag)\(String(repeating: " ", count: labelWidth - pair.tag.width))  \(String(repeating: "█", count: blocks)) \(pair.count)")
    }
}
