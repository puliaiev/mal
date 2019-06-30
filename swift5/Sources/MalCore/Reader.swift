import Foundation

public enum ReadError: Error {
    case readAtom
    case unbalanced
    case readForm
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

    for ch in input {
        switch currentMode {
        case .string:
            buffer.append(ch)
            if ch == "\"" {
                saveBuffer()
                currentMode = .normal
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
                tokens.append("~@")
            } else {
                saveBuffer()
            }
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

    if token == "(" {
        return try read_list(reader: reader)
    } else {
        return try read_atom(reader: reader)
    }
}

private func read_list(reader: Reader) throws -> MalType {
    _ = reader.next()
    var list: [MalType] = []
    while let token = reader.peek() {
        if token == ")" {
            _ = reader.next()
            return .list(list)
        } else {
            list.append(try read_form(reader: reader))
        }
    }

    throw ReadError.unbalanced
}

private func read_atom(reader: Reader) throws -> MalType {
    guard let token = reader.next() else { throw ReadError.readAtom }

    if let number = Int(token) {
        return .number(number)
    } else {
        return .atom(token)
    }
}

private extension Character {
    var string: String {
        return String(self)
    }
}
