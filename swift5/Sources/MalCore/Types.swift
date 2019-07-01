public protocol MalType: CustomStringConvertible {}

public struct Atom: MalType {
    let value: String
}

public struct List: MalType {
    let list: [MalType]
}

public struct Vector: MalType {
    let vector: [MalType]
}

public struct HashMap: MalType {
    let elements: [MalType]
}

public struct Number: MalType {
    let value: Int
}

public struct MalString: MalType {
    let value: String
}

public struct MalNil: MalType {}

public struct MalTrue: MalType {}

public struct MalFalse: MalType {}

public struct Keyword: MalType {
    let value: String
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
