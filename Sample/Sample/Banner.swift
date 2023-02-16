import UIKit
import BidOnMediationSdk

class Banner: BaseController {
    
    @IBOutlet weak var banner: BidOnMediationSdk.Banner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        banner.delegate = self
        banner.controller = self
    }
    
    override func loadButtonAction(_ sender: UIButton) {
        super.loadButtonAction(sender)
        
        banner.loadAd {
            $0.appendAdSize(.banner)
                .appendTimeout(20)
            $0.prebidConfig.appendTimeout(5)
                .appendAdUnit(NetworkDefines.bidmachine.name, [:])
                .appendAdUnit(NetworkDefines.applovin.name, ["unitId":"YOUR_ID"])
            
            $0.postbidConfig.appendTimeout(5)
                .appendAdUnit(NetworkDefines.bidmachine.name, [:])
                .appendAdUnit(NetworkDefines.admob.name, ["lineItems" : [
                    ["price" : 10, "unitId" : "ca-app-pub-3940256099942544/2934735716"],
                    ["price" : 9, "unitId" : "ca-app-pub-3940256099942544/2934735716"],
                    ["price" : 8, "unitId" : "ca-app-pub-3940256099942544/2934735716"],
                    ["price" : 7, "unitId" : "ca-app-pub-3940256099942544/2934735716"],
                    ["price" : 6, "unitId" : "ca-app-pub-3940256099942544/2934735716"],
                    ["price" : 5, "unitId" : "ca-app-pub-3940256099942544/2934735716"]
                ]])
        }
    }
}

extension Banner: DisplayAdDelegate {
    
    func adDidLoad(_ ad: DisplayAd) {
        switchState(.idle)
    }
    
    func adFailToLoad(_ ad: DisplayAd, with error: Error) {
        switchState(.idle)
    }
    
    func adFailToPresent(_ ad: DisplayAd, with error: Error) {
        switchState(.idle)
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
