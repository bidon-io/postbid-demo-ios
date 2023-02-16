import UIKit
import AppLovinSDK
import BidOnMediationSdk

class ApplovinRewardedAdapter: NSObject, MediationAdapterProtocol {
    
    weak var loadingDelegate: MediationAdapterLoadingDelegate?
    
    weak var displayDelegate: MediationAdapterDisplayDelegate?
    
    var adapterParams: MediationAdapterParamsProtocol
    
    var adapterPrice: Double {
        return revenue * 1000
    }
    
    var adapterReady: Bool {
        return rewarded?.isReady ?? false
    }
    
    private var revenue: Double = 0
    
    private var rewarded: MARewardedAd?
    
    required init(_ params: MediationParams) {
        adapterParams = ApplovinAdapterParams(params)
    }
    
    func load() {
        guard
            let config = self.adapterParams as? ApplovinAdapterParams,
            let unitId = config.config?.unitId
        else {
            loadingDelegate.flatMap { $0.failLoad(self, MediationError.loadingError("Applovin unitId is null"))}
            return
        }
        
        let rewarded = MARewardedAd.shared(withAdUnitIdentifier: unitId)
        rewarded.delegate = self
        
        rewarded.load()
        self.rewarded = rewarded
    }
    
    func present() {
        guard
            let rewarded = self.rewarded
        else {
            self.displayDelegate.flatMap { $0.didFailPresent(self, MediationError.presentError("Applovin rewarded"))}
            return;
        }
        rewarded.show()
    }
}

extension ApplovinRewardedAdapter: MARewardedAdDelegate {

    func didLoad(_ ad: MAAd) {
        revenue = ad.revenue
        self.loadingDelegate.flatMap { $0.didLoad(self) }
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        self.loadingDelegate.flatMap { $0.failLoad(self, MediationError.noContent(error.description)) }
    }
    
    func didDisplay(_ ad: MAAd) {
        self.displayDelegate.flatMap { $0.willPresentScreen(self) }
        self.displayDelegate.flatMap { $0.didTrackImpression(self) }
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        self.displayDelegate.flatMap { $0.didFailPresent(self, MediationError.presentError(error.description)) }
    }
    
    func didHide(_ ad: MAAd) {
        self.displayDelegate.flatMap { $0.didDismissScreen(self) }
    }
    
    func didClick(_ ad: MAAd) {
        self.displayDelegate.flatMap { $0.didTrackInteraction(self) }
    }
    
    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        self.displayDelegate.flatMap { $0.didTrackReward(self) }
    }
    
    func didStartRewardedVideo(for ad: MAAd) {
        
    }
    
    func didCompleteRewardedVideo(for ad: MAAd) {
        
    }
}
