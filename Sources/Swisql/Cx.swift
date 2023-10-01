public class Cx: ValueStore {
    public override init() {}
    
    public func startTx() -> Tx {
        return Tx(self)
    }
}
