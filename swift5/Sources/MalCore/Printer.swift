import Foundation

public func pr_str(ast: MalType) -> String {
    var result: String = ""

    switch ast {
    case .atom(let string):
        result.append(string)
    case .list(let list):
        result.append("(")
        result.append(list.map { pr_str(ast: $0) }.joined(separator: " "))
        result.append(")")
    case .number(let number):
        result.append("\(number)")
    }

    return result
}
