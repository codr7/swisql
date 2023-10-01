public class Definition {
    public let name: String

    public init(_ name: String) {
        self.name = name
    }

    public var sqlName: String {
        get { "\"\(name)\"" }
    }

    public func create(inTx tx: Tx) throws {
        fatalError("Not implemented")
    }

    public func drop(inTx tx: Tx) throws {
        fatalError("Not implemented")
    }
}
