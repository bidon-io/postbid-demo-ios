import Foundation

public protocol MediationNetworkProtocol {

    var networkName: String { get }

    var delegate: MediationNetworkDelegate? { get set }

    
    init()

    func initializeNetwork(_ params: MediationParams)
    
    func adapter(_ type: MediationType, _ placement: MediationPlacement) -> MediationAdapterProtocol.Type?
}


public protocol MediationNetworkDelegate: AnyObject {
    
    func didInitialized(_ network: MediationNetworkProtocol)
    
    func didFailInitialized(_ network: MediationNetworkProtocol, _ error: Error)
}

