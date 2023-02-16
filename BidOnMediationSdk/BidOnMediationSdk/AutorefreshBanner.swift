import UIKit

@objc (BMMAutorefreshBanner) public final
class AutorefreshBanner: UIView {
    
    private weak var _delegate: DisplayAdDelegate?
    
    private weak var _controller: UIViewController?
    
    private var banner: Banner?
    
    private var cachedBanner: Banner?
    
    private var isAdOnScreen: Bool = false
    
    private var isShowWhenLoad: Bool = false
    
    private var reloadTimer: Timer?
    
    private var refreshTimer: Timer?
    
    private lazy var request: Request = {
        let request = Request()
        request.appendAdSize(.banner)
        return request
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.clipsToBounds = true
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        isShowWhenLoad = !isAdOnScreen
        if !isAdOnScreen, isReady {
            presentBanner()
        }
    }
}

extension AutorefreshBanner: DisplayAd {
    
    public var delegate: DisplayAdDelegate? {
        get { return _delegate }
        set { _delegate = newValue }
    }
    
    public var controller: UIViewController? {
        get { return _controller }
        set { _controller = newValue }
    }
    
    public var isReady: Bool {
        return cachedBanner.flatMap { $0.isReady } ?? false
    }
    
    public var price: Double {
        return cachedBanner.flatMap { $0.price } ?? 0
    }
    
    public func loadAd(_ builder: RequestBuilder) {
        self.request = {
            let request = Request()
            request.appendAdSize(.banner)
            return request
        }()
        builder(self.request)
        
        if !isAdOnScreen, !isReady {
            cacheBanner()
        } else if !isAdOnScreen {
            presentBanner()
        }
    }
    
    public func loadAd() {
        self.loadAd { _ in }
    }
    
    @objc public func hideAd() {
        if isAdOnScreen {
            isAdOnScreen = false
            self.subviews.forEach { $0.removeFromSuperview() }
        }
    }
}

private extension AutorefreshBanner {
    
    func presentBanner() {
        isShowWhenLoad = false
        isAdOnScreen = true
        
        if refreshTimer != nil {
            return
        }
        
        guard let banner = cachedBanner, banner.isReady, controller != nil else {
            return
        }
        
        if isReady {
            self.subviews.forEach { $0.removeFromSuperview() }
            self.banner = banner
            self.addSubview(banner)
            [banner.topAnchor.constraint(equalTo: self.topAnchor),
             banner.leftAnchor.constraint(equalTo: self.leftAnchor),
             banner.rightAnchor.constraint(equalTo: self.rightAnchor),
             banner.bottomAnchor.constraint(equalTo: self.bottomAnchor)].forEach { $0.isActive = true }
            
            cacheBanner()
            refreshBannerIfNeeded()
        }
    }
}

private extension AutorefreshBanner {
    
    func refreshBannerIfNeeded() {
        if refreshTimer != nil {
            return
        }
        
        if isReady {
            presentBanner()
        } else {
            refreshTimer = Timer.scheduledTimer(timeInterval: 15,
                                                target: self,
                                                selector: #selector(refreshBanner),
                                                userInfo: nil,
                                                repeats: false)
        }
    }
    
    @objc func refreshBanner() {
        refreshTimer = nil
        if isReady, isAdOnScreen {
            presentBanner()
        }
    }
}

private extension AutorefreshBanner {
    
    func cacheBannerIfNeeded() {
        if reloadTimer == nil {
            reloadTimer = Timer.scheduledTimer(timeInterval: 2,
                                               target: self,
                                               selector: #selector(cacheBanner),
                                               userInfo: nil,
                                               repeats: false)
        }
    }
    
    @objc func cacheBanner() {
        reloadTimer = nil
        cachedBanner = nil
        
        let banner = Banner(frame: self.frame)
        cachedBanner = banner
        banner.delegate = self
        banner.controller = controller
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.loadAd { builder in builder
                .appendAdSize(self.request.size)
                .appendTimeout(self.request.timeout)
                .appendPriceFloor(self.request.priceFloor)
            
            builder.prebidConfig.appendTimeout(self.request._prebidConfig.timeout)
            builder.postbidConfig.appendTimeout(self.request._postbidConfig.timeout)
            
            self.request._prebidConfig.adapterParams.forEach { pair in
                builder.prebidConfig.appendAdUnit(pair.name, pair.params)
            }
            self.request._postbidConfig.adapterParams.forEach { pair in
                builder.postbidConfig.appendAdUnit(pair.name, pair.params)
            }
        }
    }
    
}

extension AutorefreshBanner: DisplayAdDelegate {
    
    public func adDidLoad(_ ad: DisplayAd) {
        guard let banner = ad as? Banner else {
            self.adFailToLoad(ad, with: MediationError.noContent("Autorefresh cached banner should be Banner"))
            return
        }
        cachedBanner = banner
        if isShowWhenLoad {
            presentBanner()
        } else if isAdOnScreen {
            refreshBannerIfNeeded()
        }
        self.delegate.flatMap { $0.adDidLoad(self) }
    }
    
    public func adFailToLoad(_ ad: DisplayAd, with error: Error) {
        cacheBannerIfNeeded()
        self.delegate.flatMap { $0.adFailToLoad(self, with: error) }
    }
    
    public func adFailToPresent(_ ad: DisplayAd, with error: Error) {
        cacheBannerIfNeeded()
        self.delegate.flatMap { $0.adFailToPresent(self, with: error) }
    }
    
    public func adWillPresentScreen(_ ad: DisplayAd) {
        self.delegate.flatMap { $0.adWillPresentScreen(self) }
    }
    
    public func adDidDismissScreen(_ ad: DisplayAd) {
        self.delegate.flatMap { $0.adDidDismissScreen(self) }
    }
    
    public func adRecieveUserAction(_ ad: DisplayAd) {
        self.delegate.flatMap { $0.adRecieveUserAction(self) }
    }
    
    public func adDidTrackImpression(_ ad: DisplayAd) {
        self.delegate.flatMap { $0.adDidTrackImpression(self) }
    }
    
    public func adDidExpired(_ ad: DisplayAd) {
        self.delegate.flatMap { $0.adDidExpired(self) }
    }
}
