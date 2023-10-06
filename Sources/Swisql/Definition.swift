public protocol Definition {
    var createSql: String {get}
    var definitionType: String {get}
    var dropSql: String {get}
    var name: String {get}
    var sqlName: String {get}
    
    func create(inTx: Tx) async throws
    func drop(inTx: Tx) async throws
    func exists(inTx: Tx) async throws -> Bool
}

public extension Definition {
    func create(inTx tx: Tx) async throws {
        try await tx.exec(self.createSql)
    }

    func drop(inTx tx: Tx) async throws {
        try await tx.exec(self.dropSql)
    }    
}

public class BasicDefinition {
    public let name: String

    public init(_ name: String) {
        self.name = name
    }

    public var sqlName: String {
        "\"\(name)\""
    }
}

public func createSql(_ d: Definition) -> String {
    "CREATE \(d.definitionType) \(d.sqlName)"
}

public func dropSql(_ d: Definition) -> String {
    "DROP \(d.definitionType) \(d.sqlName)"
}
