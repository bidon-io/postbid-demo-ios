import UIKit
import GoogleMobileAds
import BidOnMediationSdk

class AdMobInterstitialAdapter: NSObject, MediationAdapterProtocol {
    
    weak var loadingDelegate: MediationAdapterLoadingDelegate?
    
    weak var displayDelegate: MediationAdapterDisplayDelegate?
    
    var adapterParams: MediationAdapterParamsProtocol
    
    var adapterPrice: Double {
        return CPM
    }
    
    var adapterReady: Bool {
        return isLoaded
    }
    
    private var CPM: Double = 0
    
    private var isLoaded: Bool = false
    
    private var interstitial: GADInterstitialAd?
    
    required init(_ params: MediationParams) {
        adapterParams = AdMobAdapterParams(params)
    }
    
    func load() {
        guard
            let config = self.adapterParams as? AdMobAdapterParams,
            let lineItems = config.config?.lineItems,
            let lineItem = lineItems.lineItemWithPrice(config.price)
        else {
            loadingDelegate.flatMap { $0.failLoad(self, MediationError.loadingError("Can't find AdMob line item"))}
            return
        }
        
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: lineItem.unitId, request: request) { [weak self] interstitial, error in
            guard let interstitial = interstitial, let self = self, error == nil else  {
                self.flatMap { $0.loadingDelegate?.failLoad($0, MediationError.noContent(error.flatMap { $0.localizedDescription } ?? ""))}
                return
            }
            
            interstitial.fullScreenContentDelegate = self
        
            self.CPM = lineItem.price
            self.isLoaded = true
            self.interstitial = interstitial
            self.loadingDelegate.flatMap { $0.didLoad(self) }
        }
    }
    
    func present() {
        guard
            let interstitial = interstitial,
            let controller = self.adapterParams.controller
        else {
            self.displayDelegate.flatMap { $0.didFailPresent(self, MediationError.presentError("AdMob Interstitial"))}
            return
        }
        interstitial.present(fromRootViewController: controller)
    }
}

extension AdMobInterstitialAdapter: GADFullScreenContentDelegate {
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.displayDelegate.flatMap { $0.willPresentScreen(self) }
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        self.displayDelegate.flatMap { $0.didFailPresent(self, error) }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.displayDelegate.flatMap { $0.didDismissScreen(self) }
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        self.displayDelegate.flatMap { $0.didTrackImpression(self) }
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        self.displayDelegate.flatMap { $0.didTrackInteraction(self) }
    }
}
