public protocol MalType: CustomStringConvertible {}

public struct Atom: MalType {
    public let value: String

    public init(value: String) {
        self.value = value
    }
}

public struct List: MalType {
    public let list: [MalType]

    public init(list: [MalType]) {
        self.list = list
    }
}

public struct Vector: MalType {
    public let vector: [MalType]

    public init(vector: [MalType]) {
        self.vector = vector
    }
}

public struct HashMap: MalType {
    public let elements: [MalType]

    public init(elements: [MalType]) {
        self.elements = elements
    }
}

public struct Number: MalType {
    public let value: Int

    public init(value: Int) {
        self.value = value
    }
}

public struct MalString: MalType {
    public let value: String
}

public struct MalNil: MalType {
    public init() {}
}

public struct MalTrue: MalType {}

public struct MalFalse: MalType {}

public struct Keyword: MalType {
    public let value: String
}

public struct MalFunction: MalType {
    public let body: ([MalType]) throws -> MalType

    public init(body: @escaping ([MalType]) throws -> MalType) {
        self.body = body
    }

    public func apply(arguments: [MalType]) throws -> MalType {
        return try body(arguments)
    }
}

extension Atom: CustomStringConvertible {
    public var description: String {
        return value
    }
}

extension List: CustomStringConvertible {
    public var description: String {
        return "(\(list.map { pr_str(ast: $0) }.joined(separator: " ")))"
    }
}

extension Vector: CustomStringConvertible {
    public var description: String {
        return "[\(vector.map { pr_str(ast: $0) }.joined(separator: " "))]"
    }
}

extension HashMap: CustomStringConvertible {
    public var description: String {
        return "{\(elements.map { pr_str(ast: $0) }.joined(separator: " "))}"
    }
}

extension Number: CustomStringConvertible {
    public var description: String {
        return "\(value)"
    }
}

extension MalString: CustomStringConvertible {
    public var description: String {
        var buffer: String = ""
        buffer.append("\"")
        for ch in value {
            switch ch {
            case "\\":
                buffer.append("\\")
            case "\n":
                buffer.append("\\")
            case "\"":
                buffer.append("\\")
            default:
                break
            }
            buffer.append(ch)
        }
        buffer.append("\"")

        return buffer
    }
}

extension MalNil: CustomStringConvertible {
    public var description: String {
        return "nil"
    }
}

extension MalTrue: CustomStringConvertible {
    public var description: String {
        return "true"
    }
}

extension MalFalse: CustomStringConvertible {
    public var description: String {
        return "false"
    }
}

extension Keyword: CustomStringConvertible {
    public var description: String {
        return ":\(value)"
    }
}

extension MalFunction: CustomStringConvertible {
    public var description: String {
        return "function"
    }
}
