import Foundation

class PreBidOperation: AsyncOperation {
    
    private let wrapperController: MediationAdapterWrapperController
    
    private let setting: MediationSettings
    
    init(_ request: Request){
        setting = request._prebidConfig
        
        let wrappers: [MediationAdapterWrapper] = setting.adapterParams.compactMap { MediationAdapterWrapper($0, request, .prebid ) }
        wrapperController = MediationAdapterWrapperController(.prebid, setting.timeout, wrappers)
    }
    
    override func cancel() {
        if isExecuting {
            wrapperController.cancel()
        }
        super.cancel()
    }
    
    override func main() {
        wrapperController.load(self)
    }
}

extension PreBidOperation: MediationAdapterWrapperControllerDelegate {
    
    func controllerDidComplete(_ controller: MediationAdapterWrapperController) {
        guard isExecuting else { return }
        self.state = .finished
    }
}

extension PreBidOperation: BidOperation {
    
    func adaptorWrappers() -> [MediationAdapterWrapper] {
        return wrapperController.wrappers()
    }
}
