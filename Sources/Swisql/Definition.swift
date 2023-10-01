public class Definition {
    public let name: String

    public init(_ name: String) {
        self.name = name
    }

    public var sqlName: String {
        get { "\"\(name)\"" }
    }

    public func create(in tx: Tx) throws {
        fatalError("Not implemented")
    }

    public func drop(in tx: Tx) throws {
        fatalError("Not implemented")
    }
}
