import Foundation

typealias CompletionBlock = (MediationAdapterWrapper?) -> Void

class CompletionOperation: AsyncOperation {
    
    private let completion: CompletionBlock
    
    init(_ _completion: @escaping CompletionBlock) {
        completion = _completion
    }
    
    override func main() {
        Logging.log(.mediation("----- Start mediation block"))
        
        let wrappers:[MediationAdapterWrapper] = self.dependencies.compactMap { $0 as? BidOperation }.flatMap { $0.adaptorWrappers() }
        let wrapper = wrappers.maxPriceWrapper()
        
        Logging.log(.mediation("------------ Loaded adapters: \(wrappers)"))
        if let wrapper = wrapper {
            Logging.log(.mediation("------------ 🔥🥳 Max price adapter 🥳🔥: \(wrapper) 🎉🎉🎉"))
        } else {
            Logging.log(.mediation("------------ ❌❌ Adaptor not loaded (no fill) ❌❌"))
        }
        
        Logging.log(.mediation("----- Complete mediation block"))
        
        completion(wrapper)
        self.state = .finished
    }
}
