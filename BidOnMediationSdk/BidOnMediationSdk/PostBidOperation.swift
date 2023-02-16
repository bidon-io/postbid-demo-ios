import Foundation

class PostBidOperation: AsyncOperation {
    
    private let wrapperController: MediationAdapterWrapperController
    
    private let setting: MediationSettings
    
    private let requestPrice: Double
    
    init(_ request: Request){
        setting = request._postbidConfig
        requestPrice = request.priceFloor
        
        let wrappers: [MediationAdapterWrapper] = setting.adapterParams.compactMap { MediationAdapterWrapper($0, request, .postbid ) }
        wrapperController = MediationAdapterWrapperController(.postbid, setting.timeout, wrappers)
    }
    
    override func cancel() {
        if isExecuting {
            wrapperController.cancel()
        }
        super.cancel()
    }
    
    override func main() {
        let wrappers:[MediationAdapterWrapper] = self.dependencies.compactMap { $0 as? BidOperation }.flatMap { $0.adaptorWrappers() }
        var price: Double = wrappers.maxPriceWrapper().flatMap { $0.price } ?? 0
        price = price > requestPrice ? price : requestPrice
        
        wrapperController.load(self, price)
    }
}

extension PostBidOperation: MediationAdapterWrapperControllerDelegate {
    
    func controllerDidComplete(_ controller: MediationAdapterWrapperController) {
        guard isExecuting else { return }
        self.state = .finished
    }
}

extension PostBidOperation: BidOperation {
    
    func adaptorWrappers() -> [MediationAdapterWrapper] {
        return wrapperController.wrappers()
    }
}
