import UIKit
import BidMachine
import BidMachineApiCore
import BidOnMediationSdk

class BidMachineBannerAdapter: NSObject, MediationAdapterProtocol {
    
    weak var loadingDelegate: MediationAdapterLoadingDelegate?
    
    weak var displayDelegate: MediationAdapterDisplayDelegate?
    
    var adapterParams: MediationAdapterParamsProtocol
    
    var adapterPrice: Double {
        return CPM
    }
    
    var adapterReady: Bool {
        return banner?.canShow ?? false
    }
    
    private var CPM: Double = 0
    
    private var banner: BidMachineBanner?
    
    required init(_ params: MediationParams) {
        adapterParams = BidMachineAdapterParams(params)
    }
    
    func load() {
        let config = try? BidMachineSdk.shared.requestConfiguration(adapterParams.size.bannerSize())
        config?.populate {
            if adapterParams.price > 0 {
                $0.appendPriceFloor(adapterParams.price, "mediation_price")
            }
        }
        BidMachineSdk.shared.banner(config){ [weak self] (ad, error) in
            guard let self = self else {
                return
            }
            guard let ad = ad else {
                self.loadingDelegate?.failLoad(self, error!)
                return
            }
            self.banner = ad
            
            ad.delegate = self
            ad.loadAd()
        }
    }
    
    func present() {
        guard let view = adapterParams.container, let controller = adapterParams.controller else {
            self.displayDelegate.flatMap { $0.didFailPresent(self, MediationError.presentError("BidMachine banner. Controller can't be nil"))}
            return;
        }
        
        guard let banner = banner else{
            self.displayDelegate.flatMap { $0.didFailPresent(self, MediationError.presentError("BidMachine banner.Ad can't be nil"))}
            return
        }
        
        banner.controller = controller
        banner.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(banner)
        [banner.topAnchor.constraint(equalTo: view.topAnchor),
         banner.leftAnchor.constraint(equalTo: view.leftAnchor),
         banner.rightAnchor.constraint(equalTo: view.rightAnchor),
         banner.bottomAnchor.constraint(equalTo: view.bottomAnchor)].forEach { $0.isActive = true }
    }
}

extension BidMachineBannerAdapter: BidMachineAdDelegate {
    
    func didLoadAd(_ ad: BidMachine.BidMachineAdProtocol) {
        self.CPM = ad.auctionInfo.price
        self.loadingDelegate.flatMap { $0.didLoad(self) }
    }
    
    func didFailLoadAd(_ ad: BidMachine.BidMachineAdProtocol, _ error: Error) {
        self.loadingDelegate.flatMap { $0.failLoad(self, error) }
    }
    
    func didPresentAd(_ ad: BidMachine.BidMachineAdProtocol) {
        // NO-OP
    }
    
    func didFailPresentAd(_ ad: BidMachine.BidMachineAdProtocol, _ error: Error) {
        // NO-OP
    }
    
    func didDismissAd(_ ad: BidMachine.BidMachineAdProtocol) {
        // NO-OP
    }
    
    func willPresentScreen(_ ad: BidMachine.BidMachineAdProtocol) {
        self.displayDelegate.flatMap { $0.willPresentScreen(self) }
    }
    
    func didDismissScreen(_ ad: BidMachine.BidMachineAdProtocol) {
        self.displayDelegate.flatMap { $0.didDismissScreen(self) }
    }
    
    func didUserInteraction(_ ad: BidMachine.BidMachineAdProtocol) {
        self.displayDelegate.flatMap { $0.didTrackInteraction(self) }
    }
    
    func didExpired(_ ad: BidMachine.BidMachineAdProtocol) {
        self.displayDelegate.flatMap { $0.didTrackExpired(self) }
    }
    
    func didTrackImpression(_ ad: BidMachine.BidMachineAdProtocol) {
        self.displayDelegate.flatMap { $0.didTrackImpression(self) }
    }
    
    func didTrackInteraction(_ ad: BidMachine.BidMachineAdProtocol) {
        // NO-OP
    }
}

private extension MediationSize {
    
    func bannerSize() -> PlacementFormat {
        switch self {
        case .unowned: return .banner
        case .banner: return .banner320x50
        case .mrec: return .banner300x250
        case .leaderboard: return .banner728x90
        @unknown default:
            return .banner
        }
    }
    
}
