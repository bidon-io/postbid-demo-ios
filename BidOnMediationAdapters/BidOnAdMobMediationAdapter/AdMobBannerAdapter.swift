import UIKit
import GoogleMobileAds
import BidOnMediationSdk

class AdMobBannerAdapter: NSObject, MediationAdapterProtocol {
    
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
    
    private var banner: GADBannerView?
    
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
        
        CPM = lineItem.price
        
        let banner = GADBannerView(adSize: GADAdSize(size: config.size.bannerSize(), flags: 0))
        banner.delegate = self
        banner.translatesAutoresizingMaskIntoConstraints = false
        
        let request = GADRequest()
        banner.adUnitID = lineItem.unitId
        banner.rootViewController = config.controller
        banner.load(request)

        self.banner = banner
    }
    
    func present() {
        guard
            let view = adapterParams.container,
            let banner = self.banner
        else {
            self.displayDelegate.flatMap { $0.didFailPresent(self, MediationError.presentError("AdMob banner"))}
            return;
        }
        
        view.addSubview(banner)
        [banner.topAnchor.constraint(equalTo: view.topAnchor),
         banner.leftAnchor.constraint(equalTo: view.leftAnchor),
         banner.rightAnchor.constraint(equalTo: view.rightAnchor),
         banner.bottomAnchor.constraint(equalTo: view.bottomAnchor)].forEach { $0.isActive = true }
    }
}

extension AdMobBannerAdapter: GADBannerViewDelegate {
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        isLoaded = true
        self.loadingDelegate.flatMap { $0.didLoad(self) }
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        self.loadingDelegate.flatMap { $0.failLoad(self, error) }
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        self.displayDelegate.flatMap { $0.willPresentScreen(self) }
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        self.displayDelegate.flatMap { $0.didDismissScreen(self) }
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        self.displayDelegate.flatMap { $0.didTrackImpression(self) }
    }
    
    func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        self.displayDelegate.flatMap { $0.didTrackInteraction(self) }
    }
}

private extension MediationSize {
    
    func bannerSize() -> CGSize {
        switch self {
        case .unowned: return CGSize(width: 320, height: 50)
        case .banner: return CGSize(width: 320, height: 50)
        case .mrec: return CGSize(width: 300, height: 250)
        case .leaderboard: return CGSize(width: 728, height: 90)
        @unknown default:
            return CGSize(width: 320, height: 50)
        }
    }
}


