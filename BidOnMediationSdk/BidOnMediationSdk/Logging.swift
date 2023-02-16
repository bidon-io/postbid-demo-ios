import Foundation

@objc (BMMLogging) public
class Logging: NSObject {
    
    internal static let shared = Logging()
    
    private var isMediation: Bool = false
    
    private var isAdapter: Bool = false
    
    private var isNetwork: Bool = false
    
    private var isCallback: Bool = false
    
    private override init() {
        
    }
}
 
extension Logging: MediationLogger {
    
    public static var sharedLog: MediationLogger {
        return shared
    }
    
    public func enableMediationLog(_ flag: Bool) {
        self.isMediation = flag
    }
    
    public func enableAdapterLog(_ flag: Bool) {
        self.isAdapter = flag
    }
    
    public func enableNetworkLog(_ flag: Bool) {
        self.isNetwork = flag
    }
    
    public func enableAdCallbackLog(_ flag: Bool) {
        self.isCallback = flag
    }
}

extension Logging {
    
    enum LogType {
        case mediation(_ fmt: String)
        case adapter(_ fmt: String)
        case network(_ fmt: String)
        case callback(_ fmt: String)
        
        func printLog() {
            var result: String?
            var isEnable: Bool = false
            switch self {
            case .mediation(let fmt): result = "[Mediation] \(fmt)"; isEnable = Logging.shared.isMediation; break
            case .adapter(let fmt): result = "[Adapter] \(fmt)"; isEnable =  Logging.shared.isAdapter; break
            case .network(let fmt): result = "[Network] \(fmt)"; isEnable = Logging.shared.isNetwork; break
            case .callback(let fmt): result = "[Callback] \(fmt)"; isEnable = Logging.shared.isCallback; break
            }
            
            if result != nil && isEnable {
                print("[BidOnMediation]\(result!.capitalized)")
            }
        }
    }
    
    static func log(_ type: LogType) {
        type.printLog()
    }
}
