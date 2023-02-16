import BidMachine
import BidOnMediationSdk

class BidMachineNework: MediationNetworkProtocol {
    
    var networkName: String = NetworkDefines.bidmachine.name
    
    weak var delegate: MediationNetworkDelegate?
    
    func initializeNetwork(_ params: MediationParams) {
        if BidMachineSdk.shared.isInitialized {
            delegate.flatMap { $0.didInitialized(self) }
            return
        }
        
        guard let config = BidMachineNeworkParams(params).config else {
            delegate.flatMap { $0.didFailInitialized(self, MediationError.initializeError("BidMachine initialization params is null"))}
            return
        }
        
        let testMode = config.testMode.flatMap{ $0 as NSString }.flatMap { $0.boolValue } ?? false
        BidMachineSdk.shared.populate {
            $0.withTestMode(testMode)
        }
        BidMachineSdk.shared.targetingInfo.populate {
            if let storeId = config.storeId  {
                $0.withStoreId(storeId)
            }
        }
        
        BidMachineSdk.shared.initializeSdk( config.sourceId)
        self.delegate?.didInitialized(self)
    }
    
    func adapter(_ type: MediationType, _ placement: MediationPlacement) -> MediationAdapterProtocol.Type? {
        return placement.adapter()
    }
    
    required init() {
        
    }
}

extension MediationPlacement {
    func adapter() -> MediationAdapterProtocol.Type? {
        switch self {
        case .banner: return BidMachineBannerAdapter.self
        case .interstitial: return BidMachineInterstitialAdapter.self
        case .rewarded: return BidMachineRewardedAdapter.self
        default: return nil
        }
    }
}

