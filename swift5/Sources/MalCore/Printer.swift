import Foundation

public func pr_str(ast: MalType, print_readably: Bool = true) -> String {
    return ast.description
}

private extension String {
    var printReadably: String {
        var buffer: String = ""
        buffer.append("\"")
        for ch in self {
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
