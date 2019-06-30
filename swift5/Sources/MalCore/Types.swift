public enum MalType {
    case atom(String)
    case list([MalType])
    case number(Int)

    public var atomValue: String? {
        if case let MalType.atom(string) = self {
            return string
        } else {
            return nil
        }
    }

    public var number: Int? {
        if case let MalType.number(number) = self {
            return number
        } else {
            return nil
        }
    }
}
