import Foundation

protocol MediationAdapterWrapperControllerDelegate: AnyObject {
    
    func controllerDidComplete(_ controller: MediationAdapterWrapperController)
}

class MediationAdapterWrapperController {
    
    private weak var delegate: MediationAdapterWrapperControllerDelegate?
    
    private var concurentWrappers: [MediationAdapterWrapper] = []
    
    private var loadedWrappers: [MediationAdapterWrapper] = []
    
    private var timer: Timer?
    
    private var isCanceled: Bool = false
    
    private var mediationTime: Double = 0
    
    private let type: MediationType
    
    private let timeout: Double
    
    init(_ _type: MediationType, _ _timeout: Double, _ wrappers:  [MediationAdapterWrapper]) {
        concurentWrappers = wrappers
        timeout = _timeout
        type = _type
    }
}

private extension MediationAdapterWrapperController {
    
    func notifyMediationCompleteIfNeeded() {
        guard (isCanceled == true || self.concurentWrappers.count == 0) && delegate != nil else {
            return
        }
        
        let time = Date().timeIntervalSince1970 - self.mediationTime
        
        if (self.isCanceled) {
            Logging.log(.mediation("----- ❌❌ Canceled \(type.name) block (TIMEOUT) ❌❌"))
        }
        
        Logging.log(.mediation("------------ Loaded adapters: \(loadedWrappers)"))
        Logging.log(.mediation("----- Complete \(type.name) block - \(Double(round(1000 * time))) ms"))
        self.delegate.flatMap { $0.controllerDidComplete(self) }
        self.delegate = nil
    }
}

extension MediationAdapterWrapperController {
    
    func wrappers() -> [MediationAdapterWrapper] {
        return loadedWrappers
    }
    
    func load(_ delegate: MediationAdapterWrapperControllerDelegate, _ price: Double = 0) {
        guard concurentWrappers.count > 0 else {
            delegate.controllerDidComplete(self)
            return
        }
        
        self.mediationTime = Date().timeIntervalSince1970
        Logging.log(.mediation("----- Start \(type.name) block"))
        
        Logging.log(.mediation("------- Mediated adapters: \(concurentWrappers)"))
        Logging.log(.mediation("------- Mediated price: \(price)"))
        
        self.timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false, block: { [weak self] _ in
            self.flatMap { $0.cancel() }
        })
        
        self.delegate = delegate
        concurentWrappers.forEach { $0.load(price, self) }
    }
    
    func cancel() {
        self.timer?.invalidate()
        self.timer = nil
        
        isCanceled = true
        
        self.concurentWrappers.forEach { $0.invalidate() }
        self.notifyMediationCompleteIfNeeded()
    }
}

extension MediationAdapterWrapperController: MediationAdapterWrapperLoadingDelegate {
    
    func didLoad(_ wrapper: MediationAdapterWrapper) {
        self.concurentWrappers.removeAll { $0 == wrapper }
        self.loadedWrappers.append(wrapper)
        self.notifyMediationCompleteIfNeeded()
    }
    
    func failLoad(_ wrapper: MediationAdapterWrapper, _ error: Error) {
        self.concurentWrappers.removeAll { $0 == wrapper }
        self.notifyMediationCompleteIfNeeded()
    }
}

fileprivate extension MediationType {
    
    var name: String {
        switch self {
        case .prebid: return "Prebid"
        case .postbid: return "Postbid"
        }
    }
}
