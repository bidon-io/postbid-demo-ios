import UIKit

public protocol MediationAdapterProtocol: AnyObject  {
    
    var adapterPrice: Double { get }
    
    var adapterReady: Bool { get }
    
    var adapterParams: MediationAdapterParamsProtocol { get set }
    
    var loadingDelegate: MediationAdapterLoadingDelegate? { get set }
    
    var displayDelegate: MediationAdapterDisplayDelegate? { get set }
    
    init(_ params: MediationParams)

    func load()
    
    func present()
}

public protocol MediationAdapterLoadingDelegate: AnyObject {
    
    func didLoad(_ adapter: MediationAdapterProtocol)
    
    func failLoad(_ adapter: MediationAdapterProtocol, _ error: Error)
}

public protocol MediationAdapterDisplayDelegate: AnyObject {
    
    func willPresentScreen(_ adapter: MediationAdapterProtocol)
    
    func didFailPresent(_ adapter: MediationAdapterProtocol, _ error: Error)
    
    func didDismissScreen(_ adapter: MediationAdapterProtocol)
    
    func didTrackImpression(_ adapter: MediationAdapterProtocol)
    
    func didTrackInteraction(_ adapter: MediationAdapterProtocol)
    
    func didTrackReward(_ adapter: MediationAdapterProtocol)
    
    func didTrackExpired(_ adapter: MediationAdapterProtocol)
}
