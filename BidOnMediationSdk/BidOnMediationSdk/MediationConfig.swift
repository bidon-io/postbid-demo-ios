import Foundation

public enum MediationType: Int {
    case prebid
    case postbid
}

enum MediationPair {
    
    case pair(String, MediationParams)
    
    var name: String {
        switch self {
        case .pair(let name,_): return name
        }
    }
    
    var params: MediationParams {
        switch self {
        case .pair(_, let params): return params
        }
    }
}


class MediationSettings {
    
    private(set) var timeout: Double = 20
    
    private(set) var adapterParams: [MediationPair] = []
}

extension MediationSettings: MediationConfig {
    
    @discardableResult func appendTimeout(_ timeout: Double) -> MediationConfig {
        if timeout > 0 {
            self.timeout = timeout
        }
        return self
    }
    
    @discardableResult func appendAdUnit(_ name: String, _ params: MediationParams) -> MediationConfig {
        self.adapterParams.append(.pair(name, params))
        return self
    }
}
