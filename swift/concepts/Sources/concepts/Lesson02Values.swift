// Lesson 02: `let` makes a constant, `var` a variable. Every value has one type, fixed when the
// program is compiled; usually Swift works it out (type inference), and you can write it yourself.
// BUG02: changing a `let`. Swift refuses; if it has to change, say `var`.

enum Lesson02Values {
    static let title = "Values and types"

    static func run() {
        let name = "Call mom" // String, inferred from the literal
        var count = 0 // Int; var because it changes
        count += 1
        let ratio: Double = 0.5 // the type written out
        let done: Bool = false
        let mark: Character = "x" // one character, in double quotes too
        print("name = \(name), count = \(count), ratio = \(ratio), done = \(done), mark = \(mark)")
        print("type(of: ratio) = \(type(of: ratio)), type(of: count) = \(type(of: count))")

        // MemoryLayout tells you how many bytes a type takes. Int is 64 bits on this Mac.
        print("bytes: Int \(MemoryLayout<Int>.size), Int8 \(MemoryLayout<Int8>.size), Double \(MemoryLayout<Double>.size), Bool \(MemoryLayout<Bool>.size)")
        print("Int.max = \(Int.max), UInt8.max = \(UInt8.max)")

        // A tuple holds a few values together; labels make it readable.
        let pair = (tag: "work", count: 3)
        print("pair.tag = \(pair.tag), pair.count = \(pair.count)")
        let (tag, uses) = pair // take a tuple apart into two constants
        print("tag = \(tag), uses = \(uses)")

        // Arrays (lesson 12) know their element type: [String] holds only Strings.
        let tags: [String] = ["work", "urgent"]
        print("tags = \(tags), tags.count = \(tags.count)")

        #if BUG02
        name = "Call dad" // name is a let: once set, it stays
        #endif
    }
}
