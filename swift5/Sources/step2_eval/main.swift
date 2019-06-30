import Foundation
import MalCore

public enum EvalError: Error {
    case noValueIsFound
    case functionApply
}

let replEnv: [String: (Int, Int) -> MalType] = [
    "+": { a, b in MalType.number(a + b) },
    "-": { a, b in MalType.number(a - b) },
    "*": { a, b in MalType.number(a * b) },
    "/": { a, b in MalType.number(Int(a / b)) }
]

func read(input: String) throws -> MalType {
    return try read_str(input)
}

func evalAst(ast: MalType, replEnv: [String: (Int, Int) -> MalType]) throws -> MalType {
    switch ast {
    case .number(_):
        return ast
    case .atom(let atom):
        guard replEnv.keys.contains(atom) else { throw EvalError.noValueIsFound }
        return ast
    case .list(let list):
        guard !list.isEmpty else { return ast }
        guard list.count == 3 else {
            throw EvalError.functionApply
        }

        let args = try list.map { try eval(ast: $0, replEnv: replEnv) }

        guard let funcName = args[0].atomValue,
            let firstParam = args[1].number,
            let secondParam = args[2].number,
            let envFunc = replEnv[funcName] else { throw EvalError.functionApply }

        let result = envFunc(firstParam, secondParam)

        return result
    }
}

func eval(ast: MalType, replEnv: [String: (Int, Int) -> MalType]) throws -> MalType {
    return try evalAst(ast: ast, replEnv: replEnv)
}

func print(expr: MalType) -> String {
    return pr_str(ast: expr)
}

func rep(input: String) -> String {
    let result: String

    do {
        let ast = try read(input: input)
        let expr = try eval(ast: ast, replEnv: replEnv)
        result = print(expr: expr)
    } catch ReadError.unbalanced {
        result = "*(EOF|end of input|unbalanced).*"
    } catch {
        result = ":error \(error)"
    }

    return result
}

let testItem: String? = nil//"(1 2"

if let testItem = testItem {
    print("user> ")
    print("\(testItem)")
    let newString = rep(input: testItem)
    print("\(newString)")
} else {
    while true {
        print("user> ")
        if let input = readLine() {
            let newString = rep(input: input)
            print("\(newString)")
        }
    }
}
