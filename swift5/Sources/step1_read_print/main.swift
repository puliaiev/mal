import Foundation

func read(input: String) throws -> MalType {
    return try read_str(input)
}

func eval(ast: MalType) -> MalType {
    return ast
}

func print(expr: MalType) -> String {
    return pr_str(ast: expr)
}

func rep(input: String) -> String {
    let result: String

    do {
        let ast = try read(input: input)
        let expr = eval(ast: ast)
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
