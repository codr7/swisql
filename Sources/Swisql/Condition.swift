public protocol Condition {
    var conditionSql: String {get}
    var conditionParams: [any Encodable] {get}
}

public struct BasicCondition: Condition {
    public let conditionSql: String
    public let conditionParams: [any Encodable]

    public init(_ sql: String, _ params: [any Encodable]) {
        self.conditionSql = sql
        self.conditionParams = params
    }
}

public func ||(_ left: Condition, _ right: Condition) -> Condition {
    BasicCondition("(\(left.conditionSql)) OR (\(right.conditionSql))",
                   left.conditionParams + right.conditionParams)
}

public func foldOr(_ conds: [Condition]) -> Condition {
    conds[1...].reduce(conds[0], {$0 || $1})
}

public func &&(_ left: Condition, _ right: Condition) -> Condition {
    BasicCondition("(\(left.conditionSql)) AND (\(right.conditionSql))",
                   left.conditionParams + right.conditionParams)
}

public func foldAnd(_ conds: [Condition]) -> Condition {
    conds[1...].reduce(conds[0], {$0 || $1})
}

