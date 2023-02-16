import Foundation

class MediationAdapterWrapper: NSObject {
    
    private let adapterName: String
    
    private var adapter: MediationAdapterProtocol
    
    private weak var loadingDelegate: MediationAdapterWrapperLoadingDelegate?
    
    private weak var displayDelegate: MediationAdapterWrapperDisplayDelegate?
    
    private var mediationTime: Double = 0
    
    
    init?(_ pair: MediationPair, _ request: Request, _ _type: MediationType) {
        let registeredNetwork = NetworkRegistration.shared.network(pair.name)
        let registeredAdapterClass = registeredNetwork?.adapter(_type, request.placement)
        
        guard let registeredAdapterClass = registeredAdapterClass else { return nil }
        
        let registeredAdapter = registeredAdapterClass.init(pair.params)
        
        adapterName = pair.name
        adapter = registeredAdapter
        
        adapter.adapterParams.price = request.priceFloor
        adapter.adapterParams.size = request.size
        adapter.adapterParams.controller = request.controller
        adapter.adapterParams.container = request.container
    }
    
    override var description: String {
        return ("< \(name) : \(price) >")
    }
}

extension MediationAdapterWrapper {
    
    var name: String {
        return adapterName
    }
    
    var price: Double {
        return adapter.adapterPrice
    }
    
    var isReady: Bool {
        return adapter.adapterReady
    }
    
    func load(_ price: Double = 0, _ delegate: MediationAdapterWrapperLoadingDelegate) {
        Logging.log(.adapter("Start load adapter - \(adapterName), with price: \(price)"))
        
        self.mediationTime = Date().timeIntervalSince1970
        
        self.loadingDelegate = delegate
        adapter.loadingDelegate = self
        
        adapter.adapterParams.price = price
        adapter.load()
    }
    
    func present(_ delegate: MediationAdapterWrapperDisplayDelegate) {
        Logging.log(.adapter("Start present adapter - \(self)"))
        
        self.displayDelegate = delegate
        adapter.displayDelegate = self
        adapter.present()
    }
    
    func invalidate() {
        self.loadingDelegate = nil
        self.adapter.loadingDelegate = nil
        
        let time = Date().timeIntervalSince1970 - self.mediationTime
        Logging.log(.adapter(" ❌❌ Canceled load adapter (TIMEOUT) - \(name) - \(Double(round(1000 * time))) ms"))
    }
}

extension MediationAdapterWrapper: MediationAdapterLoadingDelegate {
    
    func didLoad(_ adapter: MediationAdapterProtocol) {
        let time = Date().timeIntervalSince1970 - self.mediationTime
        Logging.log(.adapter("Did load adapter - \(self) - \(Double(round(1000 * time))) ms"))
        
        self.loadingDelegate.flatMap { $0.didLoad(self) }
        self.loadingDelegate = nil
    }
    
    func failLoad(_ adapter: MediationAdapterProtocol, _ error: Error) {
        let time = Date().timeIntervalSince1970 - self.mediationTime
        Logging.log(.adapter("Did fail to load adapter - \(self) - \(Double(round(1000 * time))) ms, error - \(error)"))
        
        self.loadingDelegate.flatMap { $0.failLoad(self, error) }
        self.loadingDelegate = nil
    }
}

extension MediationAdapterWrapper: MediationAdapterDisplayDelegate {
    
    func willPresentScreen(_ adapter: MediationAdapterProtocol) {
        Logging.log(.adapter("Adapter - \(self) will present screen"))
        self.displayDelegate.flatMap { $0.willPresentScreen(self) }
    }
    
    func didFailPresent(_ adapter: MediationAdapterProtocol, _ error: Error) {
        Logging.log(.adapter("Adapter - \(self) did fail to present, error: \(error)"))
        self.displayDelegate.flatMap { $0.didFailPresent(self, error) }
    }
    
    func didDismissScreen(_ adapter: MediationAdapterProtocol) {
        Logging.log(.adapter("Adapter - \(self) did dismiss screen"))
        self.displayDelegate.flatMap { $0.didDismissScreen(self) }
    }
    
    func didTrackImpression(_ adapter: MediationAdapterProtocol) {
        Logging.log(.adapter("Adapter - \(self) did track impression"))
        self.displayDelegate.flatMap { $0.didTrackImpression(self) }
    }
    
    func didTrackInteraction(_ adapter: MediationAdapterProtocol) {
        Logging.log(.adapter("Adapter - \(self) did track interaction"))
        self.displayDelegate.flatMap { $0.didTrackInteraction(self) }
    }
    
    func didTrackReward(_ adapter: MediationAdapterProtocol) {
        Logging.log(.adapter("Adapter - \(self) did track reward"))
        self.displayDelegate.flatMap { $0.didTrackReward(self) }
    }
    
    func didTrackExpired(_ adapter: MediationAdapterProtocol) {
        Logging.log(.adapter("Adapter - \(self) did track expired"))
        self.displayDelegate.flatMap { $0.didTrackExpired(self) }
    }
}
