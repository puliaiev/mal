import Foundation
import MalCore

public enum EvalError: Error {
    case noValueIsFound
    case functionApply
    case unsupportedType
}

func read(input: String) throws -> MalType {
    return try read_str(input)
}

func evalAst(ast: MalType, replEnv: [String: MalType]) throws -> MalType {
    if let ast = ast as? Atom {
        guard replEnv.keys.contains(ast.value) else { throw EvalError.noValueIsFound }
        return replEnv[ast.value]!
    } else if let ast = ast as? List {
        return try List(list: ast.list.map { try eval(ast: $0, replEnv: replEnv) })
    } else if let ast = ast as? Vector {
        return try Vector(vector: ast.vector.map { try eval(ast: $0, replEnv: replEnv) })
    } else if let ast = ast as? HashMap {
        let newElements = try ast.elements.enumerated().map { index, element -> MalType in
            if index % 2 == 0 {
                return element
            } else {
                return try eval(ast: element, replEnv: replEnv)
            }
        }
        return HashMap(elements: newElements)
    } else {
        return ast
    }
}

func eval(ast: MalType, replEnv: [String: MalType]) throws -> MalType {
    guard let list = ast as? List else {
        return try evalAst(ast: ast, replEnv: replEnv)
    }
    if list.list.isEmpty {
        return list
    }

    guard list.list.count == 3 else {
        throw EvalError.functionApply
    }

    var args = try list.list.map { try eval(ast: $0, replEnv: replEnv) }

    guard let malFunc = args.removeFirst() as? MalFunction else { throw EvalError.functionApply }

    let result = try malFunc.apply(arguments: args)

    return result
}

func print(expr: MalType) -> String {
    return pr_str(ast: expr)
}

let replEnv: [String: MalType] = [
    "+": MalFunction { args in
        guard args.count == 2,
            let a = args[0] as? Number,
            let b = args[1] as? Number else { throw EvalError.functionApply }

        return Number(value: a.value + b.value) },
    "-": MalFunction { args in
        guard args.count == 2,
            let a = args[0] as? Number,
            let b = args[1] as? Number else { throw EvalError.functionApply }

        return Number(value: a.value - b.value) },
    "*": MalFunction { args in
        guard args.count == 2,
            let a = args[0] as? Number,
            let b = args[1] as? Number else { throw EvalError.functionApply }

        return Number(value: a.value * b.value) },
    "/": MalFunction { args in
        guard args.count == 2,
            let a = args[0] as? Number,
            let b = args[1] as? Number else { throw EvalError.functionApply }

        return Number(value: Int(a.value / b.value)) },
]

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

let testItem: String? = nil//"{\"a\" (+ 7 8)}"

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
