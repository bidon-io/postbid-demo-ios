import UIKit
import BidOnMediationSdk

struct ApplovinNeworkParams: MediationNetworkParamsProtocol {
    
    struct Config: Codable {

    }
    
    let config: Config?
    
    init(_ params: MediationParams) {
        
        config = params.decode()
        
    }
}

struct ApplovinAdapterParams: MediationAdapterParamsProtocol {
    
    struct Config: Codable {
        
        let unitId: String
        
        let targetingParams: [String : String]?
        
    }
    
    let config: Config?
    
    var size: MediationSize = .banner
    
    var price: Double = 0
    
    var controller: UIViewController?
    
    var container: UIView?
    
    init(_ params: MediationParams) {
        
        config = params.decode()
    }
}
