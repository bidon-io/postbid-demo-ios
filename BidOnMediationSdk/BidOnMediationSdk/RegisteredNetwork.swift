import Foundation

class RegisteredNetwork {
    
    private enum State {
        case idle
        case pending
        case ready
    }
    
    var network: MediationNetworkProtocol
    
    var params: MediationParams
    
    private var state: State = .idle
    
    init?(_ pair: MediationPair) {
        let klass = NSClassFromString(pair.name) as? MediationNetworkProtocol.Type
        guard let klass = klass else {
            return nil
        }

        params = pair.params
        network = klass.init()
    }
}

extension RegisteredNetwork {
    
    @discardableResult func initializeIfNeeded() -> Bool {
        network.delegate = self
        
        switch self.state {
        case .idle: self.state = .pending; network.initializeNetwork(params); return false
        case .pending: return false
        case .ready: return true
        }
    }
}

extension RegisteredNetwork: MediationNetworkDelegate {
    
    func didInitialized(_ network: MediationNetworkProtocol) {
        Logging.log(.network("Did initialize network: \(network.networkName)"))
        self.state = .ready
    }
    
    func didFailInitialized(_ network: MediationNetworkProtocol, _ error: Error) {
        Logging.log(.network("Did fail to initialize network: \(network.networkName), with error: \(error)"))
        self.state = .idle
    }
}
