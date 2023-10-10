public class Query: Condition, Value {
    var conditions: [Condition] = []
    var sources: [Source] = []
    var values: [Value] = []

    public init() {
    }

    public var conditionParams: [any Encodable] {
        params
    }

    public var conditionSql: String {
        sql
    }

    public var params: [any Encodable] {
        var out: [any Encodable] = []

        for v in values {
            out += v.valueParams
        }
        
        for s in sources {
            out += s.sourceParams
        }

        for c in conditions {
            out += c.conditionParams
        }

        return out
    }

    public var sql: String {
        var s = "SELECT \(values.sql)"

        if !sources.isEmpty {
            s += " FROM \(sources.sql)"
        } 

        if !conditions.isEmpty {
            s += " WHERE \(foldAnd(conditions).conditionSql)"
        }
        
        return s
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

    public func filter(_ args: Condition...) {
        for c in args { conditions.append(c) }
    }

    public func from(_ args: Source...) {
        for s in args { sources.append(s) }
    }

    public func select(_ args: Value...) {
        for v in args { values.append(v) }
    }
}
