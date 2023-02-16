import Foundation

@objc (BMMLogger) public
protocol MediationLogger {
    
    static var sharedLog: MediationLogger { get }
    
    func enableMediationLog(_ flag: Bool)
    
    func enableAdapterLog(_ flag: Bool)
    
    func enableNetworkLog(_ flag: Bool)
    
    func enableAdCallbackLog(_ flag: Bool)
    
}
