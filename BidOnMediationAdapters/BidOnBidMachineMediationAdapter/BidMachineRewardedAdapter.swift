import UIKit
import BidMachine
import BidMachineApiCore
import BidOnMediationSdk

class BidMachineRewardedAdapter: NSObject, MediationAdapterProtocol {
    
    weak var loadingDelegate: MediationAdapterLoadingDelegate?
    
    weak var displayDelegate: MediationAdapterDisplayDelegate?
    
    var adapterParams: MediationAdapterParamsProtocol
    
    var adapterPrice: Double {
        return CPM
    }
    
    var adapterReady: Bool {
        return  rewarded?.canShow ?? false
    }
    
    private var CPM: Double = 0
    
    private var rewarded: BidMachineRewarded?
    
    required init(_ params: MediationParams) {
        adapterParams = BidMachineAdapterParams(params)
    }
    
    func load() {
        let config = try? BidMachineSdk.shared.requestConfiguration(.rewarded)
        config?.populate {
            if adapterParams.price > 0 {
                $0.appendPriceFloor(adapterParams.price, "mediation_price")
            }
        }
        BidMachineSdk.shared.rewarded(config){ [weak self] (ad, error) in
            guard let self = self else {
                return
            }
            guard let ad = ad else {
                self.loadingDelegate?.failLoad(self, error!)
                return
            }
            self.rewarded = ad
            
            ad.delegate = self
            ad.loadAd()
        }
    }
    
    func present() {
        guard let controller = adapterParams.controller else {
            self.displayDelegate.flatMap { $0.didFailPresent(self, MediationError.presentError("BidMachine rewarded. Controller can't be nil"))}
            return
        }
        guard let rewarded = rewarded else {
            self.displayDelegate.flatMap { $0.didFailPresent(self, MediationError.presentError("BidMachine rewarded. Ad can't be nil"))}
            return
        }
        
        rewarded.controller = controller
        rewarded.presentAd()
    }
}

extension BidMachineRewardedAdapter: BidMachineAdDelegate {
    
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
    
    func didReceiveReward(_ ad: BidMachineAdProtocol) {
        self.displayDelegate.flatMap { $0.didTrackReward(self) }
    }
}

