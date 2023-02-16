import BidOnMediationSdk
import AppLovinSDK

class ApplovinNetwork: MediationNetworkProtocol {
    
    var networkName: String = NetworkDefines.applovin.name
    
    weak var delegate: MediationNetworkDelegate?
    
    func initializeNetwork(_ params: MediationParams) {
        if ALSdk.shared()?.isInitialized ?? false {
            delegate.flatMap { $0.didInitialized(self) }
            return
        }
        
        ALSdk.shared()?.mediationProvider = ALMediationProviderMAX
        ALSdk.shared()?.initializeSdk()
        
        delegate.flatMap { $0.didInitialized(self) }
    }
    
    func adapter(_ type: MediationType, _ placement: MediationPlacement) -> MediationAdapterProtocol.Type? {
        if type == .postbid {
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
        case .banner: return ApplovinBannerAdapter.self
        case .interstitial: return ApplovinInterstitialAdapter.self
        case .rewarded: return ApplovinRewardedAdapter.self
        default: return nil
        }
    }
}
