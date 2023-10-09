public struct Condition {
    public let sql: String
    public let params: [any Encodable]

    public init(_ sql: String, _ params: [any Encodable]) {
        self.sql = sql
        self.params = params
    }
}

public func ||(_ left: Condition, _ right: Condition) -> Condition {
    Condition("(\(left.sql)) OR (\(right.sql))", left.params + right.params)
}

public func foldOr(_ conds: [Condition]) -> Condition {
    conds[1...].reduce(conds[0], {$0 || $1})
}

public func &&(_ left: Condition, _ right: Condition) -> Condition {
    Condition("(\(left.sql)) AND (\(right.sql))", left.params + right.params)
}

public func foldAnd(_ conds: [Condition]) -> Condition {
    conds[1...].reduce(conds[0], {$0 || $1})
}

