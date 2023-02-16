import Foundation

protocol MediationAdapterWrapperLoadingDelegate: AnyObject {
    
    func didLoad(_ wrapper: MediationAdapterWrapper)
    
    func failLoad(_ wrapper: MediationAdapterWrapper, _ error: Error)
}

protocol MediationAdapterWrapperDisplayDelegate: AnyObject {
    
    func willPresentScreen(_ wrapper: MediationAdapterWrapper)
    
    func didFailPresent(_ wrapper: MediationAdapterWrapper, _ error: Error)
    
    func didDismissScreen(_ wrapper: MediationAdapterWrapper)
    
    func didTrackImpression(_ wrapper: MediationAdapterWrapper)
    
    func didTrackInteraction(_ wrapper: MediationAdapterWrapper)
    
    func didTrackReward(_ wrapper: MediationAdapterWrapper)
    
    func didTrackExpired(_ wrapper: MediationAdapterWrapper)
}
