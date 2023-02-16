import Foundation

class AsyncOperation: Operation {
    enum State: String {
        case ready, executing, finished
        
        fileprivate var keyPath: String {
            "is" + rawValue.capitalized
        }
    }
    
    var state = State.ready {
        
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
}

extension AsyncOperation {
    override open var isReady: Bool {
        super.isReady && self.state == .ready
    }
    
    override open var isExecuting: Bool {
        self.state == .executing
    }
    
    override open var isFinished: Bool {
        self.state == .finished
    }
    
    override open var isAsynchronous: Bool {
        true
    }
    
    override open func start() {
        if isCancelled {
            state = .finished
            return
        }
        DispatchQueue.main.async {
            self.main()
        }
        self.state = .executing
    }
    
    override open func cancel() {
        super.cancel()
        self.state = .finished
    }
}
