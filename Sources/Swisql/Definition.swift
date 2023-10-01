public class Definition {
    public let name: String

    public init(_ name: String) {
        self.name = name
    }

    public var createSql: String {
        get {"CREATE \(definitionType) \(sqlName)"}
    }
    
    public var definitionType: String {
        get { fatalError("Not implemented") }
    }

    public var dropSql: String {
        get {"DROP \(definitionType) \(sqlName)"}
    }

    public var sqlName: String {
        get { "\"\(name)\"" }
    }

    public func create(inTx tx: Tx) throws {
        try tx.exec(sql: createSql)
    }

    public func drop(inTx tx: Tx) throws {
        try tx.exec(sql: dropSql)
    }
}
