import UIKit
import BidOnMediationSdk

class ABanner: BaseController {
    
    @IBOutlet weak var banner: BidOnMediationSdk.AutorefreshBanner!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchState(.loading)
        banner.delegate = self
        banner.controller = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        banner.hideAd()
    }
}

extension ABanner: DisplayAdDelegate {
    
    func adDidLoad(_ ad: DisplayAd) {
        
    }
    
    func adFailToLoad(_ ad: DisplayAd, with error: Error) {
        
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
