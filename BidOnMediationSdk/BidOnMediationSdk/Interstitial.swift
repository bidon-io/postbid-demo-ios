import Foundation
import UIKit


@objc (BMMInterstitial) public
class Interstitial: NSObject {
    
    private lazy var mediationController: MediationController = {
        let controller = MediationController()
        controller.delegate = self
        return controller
    }()
    
    private weak var _delegate: DisplayAdDelegate?
    
    private weak var _controller: UIViewController?
    
    private var wrapper: MediationAdapterWrapper?
    
    private let uid = UUID().uuidString
    
    public override var description: String {
        return "[Interstitial - \(uid)][\(wrapper?.description ?? "Wo adapter")]"
    }
}

extension Interstitial: DisplayAd {
    
    public var delegate: DisplayAdDelegate? {
        get { return _delegate }
        set { _delegate = newValue }
    }
    
    public var controller: UIViewController? {
        get { return _controller }
        set { _controller = newValue }
    }

    public var isReady: Bool {
        return wrapper.flatMap { $0.isReady } ?? false
    }
    
    public var price: Double {
        return wrapper.flatMap { $0.price } ?? 0
    }
    
    public func loadAd(_ builder: RequestBuilder) {
        let request: Request = Request()
        builder(request)
        request
            .appendPlacement(.interstitial)
            .appendController(controller)
        
        guard mediationController.isAvailable else { return }
        
        Logging.log(.callback("Start load - \(self)"))
        mediationController.loadRequest(request)
    }
    
    public func loadAd() {
        self.loadAd { _ in }
    }
    
    @objc public func present() {
        guard let wrapper = self.wrapper else {
            let error = MediationError.presentError("Adapter not found")
            
            Logging.log(.callback("Fail to present - \(self), error - \(error)"))
            self.delegate.flatMap { $0.adFailToPresent(self, with: error) }
            return;
        }
        
        Logging.log(.callback("Start present - \(self)"))
        wrapper.present(self)
    }
}

extension Interstitial: MediationControllerDelegate {
    
    func controllerDidLoad(_ controller: MediationController, _ wrapper: MediationAdapterWrapper) {
        self.wrapper = wrapper
        
        Logging.log(.callback("Did load - \(self)"))
        self.delegate.flatMap { $0.adDidLoad(self) }
    }
    
    func controllerFailWithError(_ controller: MediationController, _ error: Error) {
        Logging.log(.callback("Fail to load - \(self), error - \(error)"))
        self.delegate.flatMap { $0.adFailToLoad(self, with:error) }
    }
}

extension Interstitial: MediationAdapterWrapperDisplayDelegate {
    
    func willPresentScreen(_ wrapper: MediationAdapterWrapper) {
        Logging.log(.callback("Will present screen - \(self)"))
        self.delegate.flatMap { $0.adWillPresentScreen(self) }
    }
    
    func didFailPresent(_ wrapper: MediationAdapterWrapper, _ error: Error) {
        Logging.log(.callback("Fail to present - \(self), error - \(error)"))
        self.delegate.flatMap { $0.adFailToPresent(self, with: error) }
    }
    
    func didDismissScreen(_ wrapper: MediationAdapterWrapper) {
        Logging.log(.callback("Did dismiss screen - \(self)"))
        self.delegate.flatMap { $0.adDidDismissScreen(self) }
    }
    
    func didTrackImpression(_ wrapper: MediationAdapterWrapper) {
        Logging.log(.callback("Did track impression - \(self)"))
        self.delegate.flatMap { $0.adDidTrackImpression(self) }
    }
    
    func didTrackInteraction(_ wrapper: MediationAdapterWrapper) {
        Logging.log(.callback("Did track interaction - \(self)"))
        self.delegate.flatMap { $0.adRecieveUserAction(self) }
    }
    
    func didTrackExpired(_ wrapper: MediationAdapterWrapper) {
        Logging.log(.callback("Did track expired - \(self)"))
        self.delegate.flatMap { $0.adDidExpired(self) }
    }
    
    func didTrackReward(_ wrapper: MediationAdapterWrapper) {
        Logging.log(.callback("Did track reward - \(self)"))
    }
}
