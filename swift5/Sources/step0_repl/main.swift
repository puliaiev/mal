func read(input: String) -> String {
    return input
}

func eval(ast: String) -> String {
    return ast
}

func print(expr: String) -> String {
    return expr
}

func rep(input: String) -> String {
    let ast = read(input: input)
    let expr = eval(ast: ast)
    let result = print(expr: expr)
    return result
}

while true {
    print("user> ")
    if let input = readLine() {
        let newString = rep(input: input)
        print("\(newString)")
    }
    
}
