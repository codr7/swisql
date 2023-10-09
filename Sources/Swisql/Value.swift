public protocol SqlValue {
    var paramSql: String {get}
    var valueSql: String {get}
    var valueParams: [any Encodable] {get}
    func encode(_ val: Any) -> any Encodable
}

extension SqlValue {
    public var paramSql: String {
        "?"
    }
    
    public var valueParams: [any Encodable] {
        []
    }
    
    public func encode(_ val: Any) -> any Encodable {
        val as! any Encodable
    }
}

public func ==(_ left: SqlValue, _ right: Any) -> Condition {
    Condition("\(left.valueSql) = \(left.paramSql)", [left.encode(right)])
}

extension [any SqlValue] {
    var sql: String {
        self.map({$0.valueSql}).joined(separator: ", ")
    }
}
