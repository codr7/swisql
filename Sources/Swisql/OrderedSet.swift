public enum Order {
    case equal
    case greater
    case less
}

public typealias Compare<L, R> = (L, R) -> Order

public struct OrderedSet<K, V> {
    let compare: Compare<K, V>
    var items: [V] = []

    public init(compare: @escaping Compare<K, V>) {
        self.compare = compare
    }

    public var count: Int {
        get {
            return items.count
        }
    }

    public subscript(key: K) -> V? {
        get {
            let (_, value) = index(of: key)
            return value
        }
        set(newValue) {
            let (i, foundValue) = index(of: key)

            if newValue == nil {
                _ = remove(key)
            } else {
                if foundValue == nil {
                    _ = add(newValue!, key: key)
                } else {
                    items[i] = newValue!
                }
            }
        }
    }

    public mutating func add(_ value: V, key: K) -> Bool {
        let (i, foundValue) = index(of: key)

        if foundValue == nil {
            items.insert(value, at: i)
            return true
        }

        return false
    }

    public func index(of key: K) -> (Int, V?) {
        var min = 0
        var max = items.count

        while min < max {
            let i = (min + max) / 2
            let value = items[i]
            
            switch compare(key, value) {
            case .equal:
                return (i, value) 
            case .greater:
                min = i + 1
            case .less:
                max = i
            }
        }
        
        return (min, nil)
    }

    public mutating func remove(_ key: K) -> V? {
        let (i, value) = index(of: key)
        
        if value != nil {
            items.remove(at: i)
        }

        return value
    }
}

public extension OrderedSet where K == V {
    mutating func add(_ value: V) -> Bool {
        return add(value, key: value)
    }
}
