public class Cx: ValueStore {
    public override init() {}

    public func close() throws {
    }
    
    public func startTx() throws -> Tx {
        Tx(self)
    }
}
