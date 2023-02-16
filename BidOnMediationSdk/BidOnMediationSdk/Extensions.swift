import Foundation

extension Array where Element == MediationAdapterWrapper {
    
    func maxPriceWrapper() -> Element? {
        return self.sorted { $0.price >= $1.price }.first
    }
}

public extension Dictionary {
    
    func decode<T: Codable>() -> T? {
        let data = try? JSONSerialization.data(withJSONObject: self)
        return data.flatMap { try? JSONDecoder().decode(T.self, from: $0) }
    }
    
}
