import UIKit
import BidOnMediationSdk

struct BidMachineNeworkParams: MediationNetworkParamsProtocol {
    
    struct Config: Codable {
        
        let sourceId: String
        let testMode: String?
        let storeId: String?
    }
    
    let config: Config?
    
    init(_ params: MediationParams) {
        
        config = params.decode()
        
    }
}

struct BidMachineAdapterParams: MediationAdapterParamsProtocol {
    
    struct Config: Codable {
        
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
