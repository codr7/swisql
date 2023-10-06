public protocol Definition {
    var name: String {get}
    var definitionType: String {get}
    var sqlName: String {get}
    
    func create(inTx tx: Tx) async throws
    func drop(inTx tx: Tx) async throws
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
