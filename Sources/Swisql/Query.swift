public class Query: SqlValue {
    var conditions: [Condition] = []
    var values: [SqlValue] = []

    public init() {}

    public var params: [any Encodable] {
        var out: [any Encodable] = []

        for v in values {
            out += v.valueParams
        }
        
        return out
    }

    public var sql: String {
        var out = "SELECT \(values.sql)"

        if !conditions.isEmpty {
            out += " WHERE \(foldAnd(conditions).sql)"
        }
        
        return out
    }

    public var valueParams: [any Encodable] {
        params
    }

    public var valueSql: String {
        sql
    }

    public func exec(inTx tx: Tx) async throws {
        _ = try await tx.query(valueSql, valueParams)
    }

    public func filter(_ conds: Condition...) {
        for c in conds { conditions.append(c) }
    }

    public func select(_ vals: SqlValue...) {
        for v in vals { values.append(v) }
    }
}
