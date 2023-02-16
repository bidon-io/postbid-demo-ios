import UIKit
import GoogleMobileAds
import BidOnMediationSdk

class AdMobRewardedAdapter: NSObject, MediationAdapterProtocol {
    
//    struct Constants {
//        
//        typealias LineItem = AdMobPostBidNetwork.LineItem
//        
//        /**
//         * Each ad unit is configured in the [AdMob dashboard](https://apps.admob.com).
//         * For each ad unit, you need to set up an eCPM floor
//         */
//        static let lineItems = [
//            LineItem(price: 1.0, unitId: "ca-app-pub-3940256099942544/1712485313"),
//            LineItem(price: 2.0, unitId: "ca-app-pub-3940256099942544/1712485313"),
//            LineItem(price: 3.0, unitId: "ca-app-pub-3940256099942544/1712485313"),
//            LineItem(price: 4.0, unitId: "ca-app-pub-3940256099942544/1712485313"),
//            LineItem(price: 5.0, unitId: "ca-app-pub-3940256099942544/1712485313"),
//            LineItem(price: 6.0, unitId: "ca-app-pub-3940256099942544/1712485313"),
//            LineItem(price: 7.0, unitId: "ca-app-pub-3940256099942544/1712485313"),
//            LineItem(price: 8.0, unitId: "ca-app-pub-3940256099942544/1712485313"),
//            LineItem(price: 9.0, unitId: "ca-app-pub-3940256099942544/1712485313"),
//            LineItem(price: 10.0, unitId: "ca-app-pub-3940256099942544/1712485313")
//        ]
//    }
    
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
    
    private var rewarded: GADRewardedAd?
    
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
        GADRewardedAd.load(withAdUnitID:  lineItem.unitId, request: request) { [weak self] rewarded, error in
            guard let rewarded = rewarded, let self = self, error == nil else  {
                self.flatMap { $0.loadingDelegate?.failLoad($0, MediationError.noContent(error.flatMap { $0.localizedDescription } ?? ""))}
                return
            }
            
            rewarded.fullScreenContentDelegate = self
        
            self.CPM = lineItem.price
            self.isLoaded = true
            self.rewarded = rewarded
            self.loadingDelegate.flatMap { $0.didLoad(self) }
        }
    }
    
    func present() {
        guard
            let rewarded = rewarded,
            let controller = self.adapterParams.controller
        else {
            self.displayDelegate.flatMap { $0.didFailPresent(self, MediationError.presentError("AdMob rewarded"))}
            return
        }
        rewarded.present(fromRootViewController: controller) { [weak self] in
            self.flatMap { $0.displayDelegate?.didTrackReward($0) }
        }
    }
}

extension AdMobRewardedAdapter: GADFullScreenContentDelegate {
    
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
