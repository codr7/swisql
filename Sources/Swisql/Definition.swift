public class Definition {
    public let name: String

    public init(_ name: String) {
        self.name = name
    }

    public var createSql: String {
        "CREATE \(definitionType) \(sqlName)"
    }
    
    public var definitionType: String {
        fatalError("Not implemented")
    }

    public var dropSql: String {
        "DROP \(definitionType) \(sqlName)"
    }

    public var sqlName: String {
        "\"\(name)\""
    }

    public func create(inTx tx: Tx) throws {
        try tx.exec(sql: createSql)
    }

    public func drop(inTx tx: Tx) throws {
        try tx.exec(sql: dropSql)
    }
}
