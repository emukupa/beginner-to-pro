// Python's text rules, as extensions on String, shared by the parser, the chart and the program.
// They work on unicodeScalars, Python's code points, not on Swift's graphemes.

// Exactly what Python's str.split() and str.strip() treat as space, as code point numbers.
let pythonSpace: Set<UInt32> = [0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x1C, 0x1D, 0x1E, 0x1F, 0x20, 0x85, 0xA0, 0x1680,
                                0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007, 0x2008, 0x2009,
                                0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000]

extension String {
    public func pythonStrip() -> String {
        trimming { pythonSpace.contains($0.value) }
    }

    public func pythonWords() -> [String] {
        var words: [String] = []
        var current = String.UnicodeScalarView()
        for scalar in unicodeScalars {
            if pythonSpace.contains(scalar.value) {
                if !current.isEmpty { words.append(String(current)); current = String.UnicodeScalarView() }
            } else {
                current.append(scalar)
            }
        }
        if !current.isEmpty { words.append(String(current)) }
        return words
    }

    // Trims any of these code points from both ends, like Python's str.strip(chars).
    func trimming(_ characters: String) -> String {
        let set = Set(characters.unicodeScalars)
        return trimming { set.contains($0) }
    }

    private func trimming(where unwanted: (Unicode.Scalar) -> Bool) -> String {
        let scalars = Array(unicodeScalars)
        guard let first = scalars.firstIndex(where: { !unwanted($0) }),
              let last = scalars.lastIndex(where: { !unwanted($0) }) else { return "" }
        return String(String.UnicodeScalarView(scalars[first...last]))
    }

    // Width in code points, as Python's len() counts.
    public var width: Int { unicodeScalars.count }
}
