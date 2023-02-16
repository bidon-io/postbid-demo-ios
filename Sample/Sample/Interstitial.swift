import UIKit
import BidOnMediationSdk

class Interstitial: BaseController {
    
    private var interstitial: BidOnMediationSdk.Interstitial?
    
    override func loadButtonAction(_ sender: UIButton) {
        super.loadButtonAction(sender)
        
        let interstitial = BidOnMediationSdk.Interstitial()
        interstitial.delegate = self
        interstitial.controller = self
        interstitial.loadAd {
            $0.appendTimeout(20)
            $0.prebidConfig.appendTimeout(5)
                .appendAdUnit(NetworkDefines.bidmachine.name, [:])
                .appendAdUnit(NetworkDefines.applovin.name, ["unitId":"YOUR_ID"])
            
            $0.postbidConfig.appendTimeout(5)
                .appendAdUnit(NetworkDefines.bidmachine.name, [:])
                .appendAdUnit(NetworkDefines.admob.name, ["lineItems" : [
                    ["price" : 10, "unitId" : "ca-app-pub-3940256099942544/4411468910"],
                    ["price" : 9, "unitId" : "ca-app-pub-3940256099942544/4411468910"],
                    ["price" : 8, "unitId" : "ca-app-pub-3940256099942544/4411468910"],
                    ["price" : 7, "unitId" : "ca-app-pub-3940256099942544/4411468910"],
                    ["price" : 6, "unitId" : "ca-app-pub-3940256099942544/4411468910"],
                    ["price" : 5, "unitId" : "ca-app-pub-3940256099942544/4411468910"]
                ]])
        }
        
        self.interstitial = interstitial
    }
    
    override func showButtonAction(_ sender: UIButton) {
        super.showButtonAction(sender)
        
        self.interstitial.flatMap { $0.present() }
    }
    
}

extension Interstitial: DisplayAdDelegate {
    
    func adDidLoad(_ ad: DisplayAd) {
        switchState(.ready)
    }
    
    func adFailToLoad(_ ad: DisplayAd, with error: Error) {
        switchState(.idle)
    }
    
    func adFailToPresent(_ ad: DisplayAd, with error: Error) {
        
    }
    
    func adWillPresentScreen(_ ad: DisplayAd) {
        
    }
    
    func adDidDismissScreen(_ ad: DisplayAd) {
        
    }
    
    func adRecieveUserAction(_ ad: DisplayAd) {
        
    }
    
    func adDidTrackImpression(_ ad: DisplayAd) {
        
    }
    
    func adDidExpired(_ ad: DisplayAd) {
        
    }
}
