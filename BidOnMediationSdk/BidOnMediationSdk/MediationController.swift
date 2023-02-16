import Foundation

protocol MediationControllerDelegate: AnyObject {
    
    func controllerDidLoad(_ controller: MediationController, _ wrapper: MediationAdapterWrapper)
    
    func controllerFailWithError(_ controller: MediationController, _ error: Error)
    
}

class MediationController {
    
    weak var delegate: MediationControllerDelegate?
    
    private(set) var isAvailable: Bool = true
    
    private var timer: Timer?
    
    private var mediationTime: Double = 0
    
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "com.bidon.mediation.module.queue"
        return queue
    }()
    
    func loadRequest(_ request: Request) {
        
        if request.controller == nil {
            self.delegate.flatMap { $0.controllerFailWithError(self, MediationError.loadingError("Controller is required parameters"))}
            return
        }
        
        let preBidOperation = PreBidOperation(request)
        let postBidOperation = PostBidOperation(request)
        let completionOperation = CompletionOperation { wrapper in
            DispatchQueue.main.async { [weak self] in
                self.flatMap { $0.complete(with: wrapper) }
            }
        }
        
        Logging.log(.mediation("----- Start mediation"))
        self.mediationTime = Date().timeIntervalSince1970
        self.timer = Timer.scheduledTimer(withTimeInterval: request.timeout, repeats: false, block: { _ in
            postBidOperation.cancel()
            preBidOperation.cancel()
        })
        
        postBidOperation.addDependency(preBidOperation)
        completionOperation.addDependency(preBidOperation)
        completionOperation.addDependency(postBidOperation)
        
        isAvailable = false
        queue.addOperations([preBidOperation, postBidOperation, completionOperation], waitUntilFinished: false)
    }
}

private extension MediationController {
    
    func complete(with wrapper: MediationAdapterWrapper?) {
        let time = Date().timeIntervalSince1970 - self.mediationTime
        Logging.log(.mediation("----- Finish mediation - \(Double(round(1000 * time))) ms"))
        self.mediationTime = Date().timeIntervalSinceNow
        
        self.timer?.invalidate()
        self.timer = nil
        
        isAvailable = true
        guard let wrapper = wrapper else {
            self.delegate.flatMap { $0.controllerFailWithError(self, MediationError.noContent("Adapter not loaded")) }
            return;
        }
        self.delegate.flatMap { $0.controllerDidLoad(self, wrapper) }
    }
    
}
