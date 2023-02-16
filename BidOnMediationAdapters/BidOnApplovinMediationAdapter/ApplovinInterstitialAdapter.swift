import UIKit
import AppLovinSDK
import BidOnMediationSdk

class ApplovinInterstitialAdapter: NSObject, MediationAdapterProtocol {
    
    weak var loadingDelegate: MediationAdapterLoadingDelegate?
    
    weak var displayDelegate: MediationAdapterDisplayDelegate?
    
    var adapterParams: MediationAdapterParamsProtocol
    
    var adapterPrice: Double {
        return revenue * 1000
    }
    
    var adapterReady: Bool {
        return interstitial?.isReady ?? false
    }
    
    private var revenue: Double = 0
    
    private var interstitial: MAInterstitialAd?
    
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
        
        let interstitial = MAInterstitialAd(adUnitIdentifier: unitId)
        interstitial.delegate = self
        
        interstitial.load()
        self.interstitial = interstitial
    }
    
    func present() {
        guard
            let interstitial = self.interstitial
        else {
            self.displayDelegate.flatMap { $0.didFailPresent(self, MediationError.presentError("Applovin rewarded"))}
            return;
        }
        interstitial.show()
    }
}

extension ApplovinInterstitialAdapter: MAAdDelegate {
    
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
}
