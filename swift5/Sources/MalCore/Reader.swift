import Foundation

public enum ReadError: Error {
    case readAtom
    case unbalanced
    case readForm
    case readContainer
}

public func read_str(_ str: String) throws -> MalType {
    let tokens = try tokenize(str)
    let reader = Reader(tokens: tokens)

    return try read_form(reader: reader)
}

private func tokenize(_ input: String) throws -> [String] {
    let specialTwoCharacters = ["~@"]
    let specialSingleCharacters = ["[", "]", "{", "}", "(", ")", "'", "`", "~", "^", "@"]

    enum Mode {
        case string, comment, normal, specialTwo
    }

    var currentMode = Mode.normal

    var tokens: [String] = []

    var buffer = ""

    func saveBuffer() {
        if !buffer.isEmpty {
            tokens.append(buffer)
        }

        buffer = ""
    }

    var slashMode = false

    for ch in input {
        switch currentMode {
        case .string:
            if slashMode {
                switch ch {
                case "\\":
                    buffer.append("\\")
                case "\n":
                    buffer.append("\n")
                case "\"":
                    buffer.append("\"")
                default:
                    buffer.append("\\")
                    buffer.append(ch)
                }
                slashMode = false
            } else {
                switch ch {
                case "\\":
                    slashMode = true
                case "\"":
                    currentMode = .normal
                    buffer.append(ch)
                    saveBuffer()
                default:
                    buffer.append(ch)
                }
            }

        case .comment:
            buffer.append(ch)
            if ch.isNewline {
                saveBuffer()
                currentMode = .normal
            }
        case .normal:
            if ch.isWhitespace || ch == "," {
                saveBuffer()
                continue
            } else if ch == "~" {
                saveBuffer()
                buffer.append(ch)
                currentMode = .specialTwo
            } else if specialSingleCharacters.contains(ch.string) {
                saveBuffer()
                tokens.append(ch.string)
            } else if ch == "\"" {
                saveBuffer()
                buffer.append(ch)
                currentMode = .string
            } else if ch == ";" {
                saveBuffer()
                buffer.append(ch)
                currentMode = .comment
            } else if ch.isNewline {
                saveBuffer()
            } else {
                buffer.append(ch)
            }
        case .specialTwo:
            if ch == "@" {
                buffer.append(ch)
            } else {
                saveBuffer()
                buffer.append(ch)
            }
            saveBuffer()
            currentMode = .normal
        }
    }

    switch currentMode {
    case .normal:
        saveBuffer()
    case .comment:
        break
    case .specialTwo:
        break
    case .string:
        throw ReadError.unbalanced
    }

    return tokens
}

private class Reader {
    private let tokens: [String]
    private var currentPosition: Int = 0

    init(tokens: [String]) {
        self.tokens = tokens
    }

    func next() -> String? {
        let currentPosition = self.currentPosition

        if currentPosition < tokens.count {
            self.currentPosition += 1
            return tokens[currentPosition]
        } else {
            return nil
        }
    }

    func peek() -> String? {
        if currentPosition < tokens.count {
            return tokens[currentPosition]
        } else {
            return nil
        }
    }
}

private func read_form(reader: Reader) throws -> MalType {
    guard let token = reader.peek() else { throw ReadError.readForm }

    if let container = try readContainer(token: token, reader: reader) {
        return container
    } else {
        return try read_atom(reader: reader)
    }
}

private func readContainer(token: String, reader: Reader) throws -> MalType? {
    let containers: [String: (String, ([MalType]) -> MalType)] = [
        "(": (")", { list in List(list: list) }),
        "[": ("]", { list in Vector(vector: list) }),
        "{": ("}", { list in HashMap(elements: list) }),
    ]

    if containers.keys.contains(token) {
        guard let container = containers[token] else { throw ReadError.readContainer }
        _ = reader.next()
        var list: [MalType] = []
        while let token = reader.peek() {
            if token == container.0 {
                _ = reader.next()
                return container.1(list)
            } else {
                list.append(try read_form(reader: reader))
            }
        }

        throw ReadError.unbalanced
    } else {
        return nil
    }
}

private func read_atom(reader: Reader) throws -> MalType {
    guard let token = reader.next() else { throw ReadError.readAtom }

    if let number = Int(token) {
        return Number(value: number)
    } else if token.first == "\"" {
        var content = token
        content.removeLast()
        content.removeFirst()
        return MalString(value: content)
    } else if token == "nil" {
        return MalNil()
    } else if token == "true" {
        return MalTrue()
    } else if token == "false" {
        return MalFalse()
    } else if token.hasPrefix(":") {
        var content = token
        content.removeFirst()
        return Keyword(value: content)
    } else if token == "'" {
        return List(list: [Atom(value: "quote"), try read_form(reader: reader)])
    } else if token == "`" {
        return List(list: [Atom(value: "quasiquote"), try read_form(reader: reader)])
    } else if token == "~" {
        return List(list: [Atom(value: "unquote"), try read_form(reader: reader)])
    } else if token == "~@" {
        return List(list: [Atom(value: "splice-unquote"), try read_form(reader: reader)])
    } else if token == "^" {
        let firstPart = try read_form(reader: reader)
        let secondPart = try read_form(reader: reader)
        return List(list: [Atom(value: "with-meta"), secondPart, firstPart])
    } else if token == "@" {
        return List(list: [Atom(value: "deref"), try read_form(reader: reader)])
    } else {
        return Atom(value: token)
    }
}

private extension Character {
    var string: String {
        return String(self)
    }
}
