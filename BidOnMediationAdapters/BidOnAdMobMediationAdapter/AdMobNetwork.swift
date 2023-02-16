import BidOnMediationSdk
import GoogleMobileAds

class AdMobNetwork: MediationNetworkProtocol {
    
    var networkName: String = NetworkDefines.admob.name
    
    weak var delegate: MediationNetworkDelegate?
    
    func initializeNetwork(_ params: MediationParams) {
        GADMobileAds.sharedInstance().start { [weak self] _ in
            self.flatMap { $0.delegate?.didInitialized($0) }
        }
    }
    
    func adapter(_ type: MediationType, _ placement: MediationPlacement) -> MediationAdapterProtocol.Type? {
        if type == .prebid {
            return nil
        }
        return placement.adapter()
    }
    
    required init() {
        
    }
}

extension MediationPlacement {
    func adapter() -> MediationAdapterProtocol.Type? {
        switch self {
        case .banner: return AdMobBannerAdapter.self
        case .interstitial: return AdMobInterstitialAdapter.self
        case .rewarded: return AdMobRewardedAdapter.self
        default: return nil
        }
    }
}

extension Array where Element == AdMobAdapterParams.Config.LineItem {
    
    func lineItemWithPrice(_ price: Double) -> Element? {
        return self.sorted { $0.price < $1.price }.filter { $0.price > price }.first
    }
    
}
