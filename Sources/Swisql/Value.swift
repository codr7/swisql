public protocol Value {
    var paramSql: String {get}
    var valueSql: String {get}
    var valueParams: [any Encodable] {get}
    func encode(_ val: Any) -> any Encodable
}

extension Value {
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

public func ==(_ left: Value, _ right: Any) -> Condition {
    BasicCondition("\(left.valueSql) = \(left.paramSql)", [left.encode(right)])
}

extension [any Value] {
    var sql: String {
        self.map({$0.valueSql}).joined(separator: ", ")
    }
}
