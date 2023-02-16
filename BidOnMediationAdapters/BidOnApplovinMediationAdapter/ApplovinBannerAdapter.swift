import UIKit
import AppLovinSDK
import BidOnMediationSdk

class ApplovinBannerAdapter: NSObject, MediationAdapterProtocol {
    
    weak var loadingDelegate: MediationAdapterLoadingDelegate?
    
    weak var displayDelegate: MediationAdapterDisplayDelegate?
    
    var adapterParams: MediationAdapterParamsProtocol
    
    var adapterPrice: Double {
        return revenue * 1000
    }
    
    var adapterReady: Bool {
        return isLoaded
    }
    
    private var revenue: Double = 0
    
    private var isLoaded: Bool = false
    
    private var banner: MAAdView?
    
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
        
        let banner = MAAdView(adUnitIdentifier: unitId, adFormat: MAAdFormat.banner)
        banner.frame = CGRect(origin: .zero, size: MAAdFormat.banner.size)
        banner.delegate = self
        
        banner.loadAd()
        self.banner = banner
    }
    
    func present() {
        guard
            let view = adapterParams.container,
            let banner = self.banner
        else {
            self.displayDelegate.flatMap { $0.didFailPresent(self, MediationError.presentError("Applovin banner"))}
            return;
        }
        
        view.addSubview(banner)
        [banner.topAnchor.constraint(equalTo: view.topAnchor),
         banner.leftAnchor.constraint(equalTo: view.leftAnchor),
         banner.rightAnchor.constraint(equalTo: view.rightAnchor),
         banner.bottomAnchor.constraint(equalTo: view.bottomAnchor)].forEach { $0.isActive = true }
    }
}

extension ApplovinBannerAdapter: MAAdViewAdDelegate {
    
    func didLoad(_ ad: MAAd) {
        isLoaded = true
        revenue = ad.revenue
        
        banner?.stopAutoRefresh()
        self.loadingDelegate.flatMap { $0.didLoad(self) }
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        self.loadingDelegate.flatMap { $0.failLoad(self, MediationError.noContent(error.description)) }
    }
    
    func didDisplay(_ ad: MAAd) {
        self.displayDelegate.flatMap { $0.didTrackImpression(self) }
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        self.displayDelegate.flatMap { $0.didFailPresent(self, MediationError.presentError(error.description)) }
    }
    
    func didClick(_ ad: MAAd) {
        self.displayDelegate.flatMap { $0.didTrackInteraction(self) }
    }
    
    func didExpand(_ ad: MAAd) {
        self.displayDelegate.flatMap { $0.willPresentScreen(self) }
    }
    
    func didCollapse(_ ad: MAAd) {
        self.displayDelegate.flatMap { $0.didDismissScreen(self) }
    }
    
    func didHide(_ ad: MAAd) {
        
    }
    
}

private extension MediationSize {
    
    func bannerSize() -> MAAdFormat {
        switch self {
        case .unowned: return MAAdFormat.banner
        case .banner: return MAAdFormat.banner
        case .mrec: return MAAdFormat.mrec
        case .leaderboard: return MAAdFormat.leader
        @unknown default:
            return MAAdFormat.banner
        }
    }
}


