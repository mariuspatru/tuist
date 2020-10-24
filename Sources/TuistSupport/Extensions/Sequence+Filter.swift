public extension Sequence {
    func filter<T>(_: T.Type) -> [T] {
        compactMap { $0 as? T }
    }
}
