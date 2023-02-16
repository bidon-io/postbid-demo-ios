import UIKit

@objc (BMMDisplayAd) public
protocol DisplayAd: AnyObject {
    
    var isReady: Bool { get }
    
    var price: Double { get }
    
    weak var delegate: DisplayAdDelegate? { get set }
    
    weak var controller: UIViewController? { get set }
    
    func loadAd(_ builder: RequestBuilder)
    
    func loadAd()
}

@objc (BMMDisplayAdDelegate) public
protocol DisplayAdDelegate: AnyObject {
    
    func adDidLoad(_ ad: DisplayAd)
    
    func adFailToLoad(_ ad: DisplayAd, with error: Error)
    
    func adFailToPresent(_ ad: DisplayAd, with error: Error)
    
    func adWillPresentScreen(_ ad: DisplayAd)
    
    func adDidDismissScreen(_ ad: DisplayAd)
    
    func adRecieveUserAction(_ ad: DisplayAd)
    
    func adDidTrackImpression(_ ad: DisplayAd)
    
    func adDidExpired(_ ad: DisplayAd)
}
