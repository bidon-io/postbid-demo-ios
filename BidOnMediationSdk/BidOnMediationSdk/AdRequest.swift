import Foundation
import UIKit

class Request {
    
    private(set) var size: MediationSize = .unowned
    
    private(set) var priceFloor: Double = 0
    
    private(set) var timeout: Double = 20
    
    private(set) var placement: MediationPlacement = .unowned
    
    private(set) weak var controller: UIViewController?
    
    private(set) weak var container: UIView?
    
    private(set) var _prebidConfig = MediationSettings()
    
    private(set) var _postbidConfig = MediationSettings()
    
}

extension Request {
    
    @discardableResult func appendPlacement(_ placement: MediationPlacement) -> Request {
        self.placement = placement
        return self
    }
    
    @discardableResult func appendController(_ controller: UIViewController?) -> Request {
        self.controller = controller
        return self
    }
    
    @discardableResult func appendContainer(_ container: UIView?) -> Request {
        self.container = container
        return self
    }
}

extension Request : AdRequest {
    
    var prebidConfig: MediationConfig {
        return self._prebidConfig
    }
    
    var postbidConfig: MediationConfig {
        return self._postbidConfig
    }
    
    
    @discardableResult func appendPriceFloor(_ price: Double) -> AdRequest {
        self.priceFloor = price
        return self
    }
    
    @discardableResult func appendTimeout(_ timeout: Double) -> AdRequest {
        if timeout > 0 {
            self.timeout = timeout
        }
        return self
    }
    
    @discardableResult func appendAdSize(_ size: MediationSize) -> AdRequest {
        self.size = size
        return self
    }
}
