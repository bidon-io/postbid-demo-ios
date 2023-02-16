import UIKit
import BidOnMediationSdk

struct AdMobNeworkParams: MediationNetworkParamsProtocol {
    
    struct Config: Codable {

    }
    
    let config: Config?
    
    init(_ params: MediationParams) {
        
        config = params.decode()
        
    }
}

struct AdMobAdapterParams: MediationAdapterParamsProtocol {
    
    struct Config: Codable {
        
        struct LineItem: Codable {
            
            let price: Double
            
            let unitId: String
            
        }
        
        let lineItems: [LineItem]
        
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
