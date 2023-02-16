import UIKit

public protocol MediationAdapterParamsProtocol {
    
    var size: MediationSize { get set }
    
    var price: Double { get set }
    
    var controller: UIViewController? { get set }
    
    var container: UIView? { get set }
    
    init(_ params: MediationParams)
}
