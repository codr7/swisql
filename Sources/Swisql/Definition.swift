public class Definition {
    public let name: String

    public init(_ name: String) {
        self.name = name
    }

    public func create(in tx: Tx) throws {
        fatalError("Not implemented")
    }

    public func drop(in tx: Tx) throws {
        fatalError("Not implemented")
    }
}
