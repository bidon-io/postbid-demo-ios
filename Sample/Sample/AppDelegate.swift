//
//  AppDelegate.swift
//  BidMachineSample
//
//  Created by Ilia Lozhkin on 15.06.2022.
//

import UIKit
import BidMachine
import AppLovinSDK
import GoogleMobileAds
import BidOnMediationSdk

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Logging.sharedLog.enableMediationLog(true)
        Logging.sharedLog.enableAdapterLog(true)
        Logging.sharedLog.enableNetworkLog(true)
        Logging.sharedLog.enableAdCallbackLog(true)
        
        self.registerNetwork()

        return true
    }
    
    func registerNetwork() {
        NetworkRegistration.shared.registerNetwork(NetworkDefines.applovin.klass, [:])
        NetworkRegistration.shared.registerNetwork(NetworkDefines.admob.klass, [:])
        NetworkRegistration.shared.registerNetwork(NetworkDefines.bidmachine.klass, ["sourceId": "1", "testMode" : "true"])
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

