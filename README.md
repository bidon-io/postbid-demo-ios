[<img src="https://img.shields.io/badge/SDK%20Version-2.0.0.0-brightgreen">](https://docs.bidmachine.io/docs/in-house-mediation-1)
[<img src="https://img.shields.io/badge/Applovin%20MAX%20Version-11.7.1-blue">](https://dash.applovin.com/documentation/mediation/ios/getting-started/integration)
[<img src="https://img.shields.io/badge/AdMob%20Version-10.0.0-blue">](https://developers.google.com/admob/ios/quick-start)

* [General PostBid logic description](#generalpostbidlogicdescription)
* [How to get AdNetwork price](#howtogetadnetworkprice)
    + [Applovin](#applovin)
    + [BidMachine](#bidmachine)
* [How to make a PostBid request](#howtomakeapostbidrequest)
    + [AdMob](#admob)
    + [BidMachine](#bidmachine-1)
* [How to make a PostBid request](#selectadstoshow)
* [BidOn-iOS-Mediation-SDK](#bidoniosmediationsdk)
    * [Get Started](#getstarted)
    * [Logging](#logging)
    * [Initialization](#initialization)
    * [Loading](#loading)
    * [Presenting](#presenting)
    * [Adaptors](#adaptors)
        + [BidMachine](#bidmachine-2)
        + [Applovin](#applovin-1)
        + [AdMob](#admob-1)

## General PostBid logic description

PostBid is a type of an integration that allows publishers to boost revenue by adding extra-layer of an auction after usual meditation has finished its work. This auction is fully controlled by the publisher and is called PostBid. Whenever mediation provides an ad with a price - publisher is asking PostBid partners if they are willing to pay more for an impression opportunity.
Flow is the following:

* Publisher requests an ad from mediation
* Mediations provide an ad with some price
* Publisher creates PostBid auction across all PostBid partners
* All partners should be requested simultaneously within PostBid auction
* Publisher chooses the winner of the auction and winner’s ad should be shown as it’s the most expensive
* If no PostBid partners were able to provide an ad - publisher should show the ad that was provided by mediation

## How to get AdNetwork price

### Applovin

After loading ads:

[Example:](BidOnMediationAdapters/BidOnApplovinMediationAdapter/ApplovinRewardedAdapter.swift#L58)

```swift

func didLoad(_ ad: MAAd) {
    let price = ad.revenue * 1000
}

```

### BidMachine

After loading ads:

[Example:](BidOnMediationAdapters/BidOnBidMachineMediationAdapter/BidMachineRewardedAdapter.swift#L69)

```swift

func didLoadAd(_ ad: BidMachine.BidMachineAdProtocol) {
    let price = ad.auctionInfo.price
}

```

## How to make a PostBid request

First you need to select the maximum price from the previously downloaded ads. <br />
Then make a request with this price

### AdMob

1. Need to have AdUnits. <br />
Each ad unit is configured in the [AdMob dashboard](https://apps.admob.com). <br />
For each ad unit, you need to set up an eCPM floor <br />
2. Find among all  adUnits that you use the one with a price that is greater or equal to final mediation price
3. Make a request with this adUnit
4. If this adUnit retuned fill - it should be used din postBid auction

[Example:](BidOnMediationAdapters/BidOnAdMobMediationAdapter/AdMobRewardedAdapter.swift#L53)

```swift

GADRewardedAd.load(withAdUnitID:  "ca-app-pub-0000000000000000/0000000000", request: request) {  }

```

### BidMachine

 1. request with price

[Example:](BidOnMediationAdapters/BidOnBidMachineMediationAdapter/BidMachineRewardedAdapter.swift#L30)

```swift

func load() {
        let config = try? BidMachineSdk.shared.requestConfiguration(.rewarded)
        config?.populate {
            $0.appendPriceFloor(10.0, "mediation_price")
        }
        BidMachineSdk.shared.rewarded(config){ [weak self] (ad, error) in
            guard let self = self else {
                return
            }
            guard let ad = ad else {
                self.loadingDelegate?.failLoad(self, error!)
                return
            }
            self.rewarded = ad
            
            ad.delegate = self
            ad.loadAd()
        }
 }

```
2. If ad returned fill, then its price can be fetched with this method

[Example:](BidOnMediationAdapters/BidOnBidMachineMediationAdapter/BidMachineRewardedAdapter.swift#L69)

```swift

func didLoadAd(_ ad: BidMachine.BidMachineAdProtocol) {
    let price = ad.auctionInfo.price
}

```

## Select ads to show

After prebid and postbid auctions, you need to select the ad with the maximum price and show it

[Example:](BidOnMediationSdk/BidOnMediationSdk/Extensions.swift#L5)

```swift

extension Array where Element == MediationAdapterWrapper {
    
    func maxPriceWrapper() -> Element? {
        return self.sorted { $0.price >= $1.price }.first
    }
}

```

# BidOn-iOS-Mediation-SDK

## Get started

To simplify the work with posbid, you can use a ready-made solution.<br />
The library already contains ready-to-use adapters **AdMob, BidMachine, Applovin**

In order to use the module, you need to add the following specs to the Podfile


```ruby

$ModuleVersion = '~> 0.0.1'

def bidon_module
  pod "BidOnMediationSdk/BidMachine", $ModuleVersion
  pod "BidOnMediationSdk/Applovin", $ModuleVersion
  pod "BidOnMediationSdk/AdMob", $ModuleVersion
end

target 'Sample' do
project 'Sample/Sample.xcodeproj'
  bidon_module
end

```

## Logging

SDK supports logging of individual sections of code

```swift

 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Logging.sharedLog.enableMediationLog(true)
        Logging.sharedLog.enableAdapterLog(true)
        Logging.sharedLog.enableNetworkLog(true)
        Logging.sharedLog.enableAdCallbackLog(true)

        return true
    }

```

## Initialization

Before using the SDK you must initialize and register the ad networks

```swift

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        BidMachineSdk.shared.populate {
            $0.withTestMode(false)
        }
        BidMachineSdk.shared.targetingInfo.populate {
            $0.withStoreId("111")
        }
        
        BidMachineSdk.shared.initializeSdk( "1" )

        self.registerNetwork()
        return true
    }

func registerNetwork() {
        NetworkRegistration.shared.registerNetwork(NetworkDefines.applovin.klass, [:])
        NetworkRegistration.shared.registerNetwork(NetworkDefines.admob.klass, [:])
        NetworkRegistration.shared.registerNetwork(NetworkDefines.bidmachine.klass, [:])
}
```

## Loading

Loading is the same across all ad types

You can set the configuration for loading in the loadAd method

> **_NOTE:_**  .controller - is required property to load ad


```swift

interstitial.delegate = self
interstitial.controller = self
interstitial.loadAd {
            $0.appendTimeout(20) 
                // .appendAdSize(.banner) // if needed (mrec, banner, leaderboard size set)
                // .appendPriceFloor(30)  // if needed (set your custom price)
            $0.prebidConfig.appendTimeout(5)
                .appendAdUnit(NetworkDefines.bidmachine.name, [:])
                .appendAdUnit(NetworkDefines.applovin.name, ["unitId":"YOUR_ID"])
            
            $0.postbidConfig.appendTimeout(5)
                .appendAdUnit(NetworkDefines.bidmachine.name, [:])
                .appendAdUnit(NetworkDefines.admob.name, ["lineItems" : [
                    ["price" : 10, "unitId" : "YOUR_ADMOB_UNIT_ID_FOR_PRICE_10"],
                    ["price" : 9, "unitId" : "YOUR_ADMOB_UNIT_ID_FOR_PRICE_9"],
                    ["price" : 8, "unitId" : "YOUR_ADMOB_UNIT_ID_FOR_PRICE_8"],
                    ["price" : 7, "unitId" : "YOUR_ADMOB_UNIT_ID_FOR_PRICE_7"],
                    ["price" : 6, "unitId" : "YOUR_ADMOB_UNIT_ID_FOR_PRICE_6"],
                    ["price" : 5, "unitId" : "YOUR_ADMOB_UNIT_ID_FOR_PRICE_5"]
                ]])
        }

```

Delegate:

```swift

extension Interstitial: DisplayAdDelegate {
    
    func adDidLoad(_ ad: DisplayAd) {
        
    }
    
    func adFailToLoad(_ ad: DisplayAd, with error: Error) {
        
    }
    
    func adFailToPresent(_ ad: DisplayAd, with error: Error) {
        
    }
    
    func adWillPresentScreen(_ ad: DisplayAd) {
        
    }
    
    func adDidDismissScreen(_ ad: DisplayAd) {
        
    }
    
    func adRecieveUserAction(_ ad: DisplayAd) {
        
    }
    
    func adDidTrackImpression(_ ad: DisplayAd) {
        
    }
    
    func adDidExpired(_ ad: DisplayAd) {
        
    }
}

```

## Presenting
**Banner** and **AutorefreshBanner** can automatically show ads when they are in a hierarchy.
For other types, you must call the display method manually

**AutorefreshBanner**

To prevent the banner from updating, it must be hidden.

```swift

banner.hideAd()

```


**Interstitial**

```swift

self.interstitial?.present()

```

**Rewarded**

```swift

self.rewarded?.present { 
	// reward callback
}

```

## Adaptors

#### Adaptor params:

|            | Class                          | Name                          |
|------------|--------------------------------|-------------------------------|
| Applovin   | NetworkDefines.applovin.klass   | NetworkDefines.applovin.name   |
| BidMachine | NetworkDefines.bidmachine.klass | NetworkDefines.bidmachine.name |
| AdMob      | NetworkDefines.admob.klass      | NetworkDefines.admob.name      |

#### Adapter bidding support: 

|            | Prebid | Postbid |
|------------|--------|---------|
| BidMachine |    +   |    +    |
| Applovin   |    +   |    -    |
| AdMob      |    -   |    +    |

### BidMachine

Initialized params :

|          | Type   | Example  |
|----------|--------|----------|
| sourceId | String | "1"      |
| testMode | String | "true"   |
| storeId  | String | "123456" |

Bidding params :

|                 | Type            | Example           |
|-----------------|-----------------|-------------------|
| targetingParams | [String:String] | ["key" : "value"] |

### Applovin

Initialized params :

Parameters for initialization are not required

Bidding params :

|        | Type   | Example |
|--------|--------|---------|
| unitId | String | "1-567" |

### AdMob

Initialized params :

Parameters for initialization are not required

Bidding params :

Each ad unit is configured in the [AdMob dashboard](https://apps.admob.com).
For each ad unit, you need to set up an eCPM floor

|           | Type                | Attachment | Type   | Example                                 |
|-----------|---------------------|------------|--------|-----------------------------------------|
| lineItems | [[String : String]] |            |        | [["price" : "1.0", "unitId" : "1-567"]] |
|           |                     | price      | String | "1.0"                                   |
|           |                     | unitId     | String | "1-567"                                 |

