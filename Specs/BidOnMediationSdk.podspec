Pod::Spec.new do |spec|
  spec.name                     = "BidOnMediationSdk"
  spec.version                  = "0.0.1"
  spec.summary                  = "BidOn iOS Mediation SDK"

  spec.homepage                 = "https://bidmachine.io"
  spec.license                  = { :type => 'GPL 3.0', :file => 'LICENSE' }
  spec.author                   = { "Stack" => "https://explorestack.com/bidmachine/" }

  spec.platform                 = :ios, '12.0'
  spec.swift_version            = "5.1"
  
  spec.pod_target_xcconfig = {
    "VALID_ARCHS": "arm64 x86_64",
    "VALID_ARCHS[sdk=iphoneos*]": "arm64",
    "VALID_ARCHS[sdk=iphonesimulator*]": "arm64 x86_64"
  }

  spec.source                   = { :http => "https://s3-us-west-1.amazonaws.com/appodeal-ios/#{spec.name}/#{spec.version}/#{spec.name}.zip" }

  spec.default_subspec = 'Core'

  spec.subspec 'Core' do |ss|
    ss.vendored_frameworks = "BidOnMediationSdk.xcframework"
  end

  spec.subspec 'BidMachine' do |ss|
    ss.vendored_frameworks = "BidOnBidMachineMediationAdapter.xcframework"
    ss.dependency 'BidMachine', '~> 2.0.0.0'
    ss.dependency 'BidOnMediationSdk/Core'
  end

  spec.subspec 'Applovin' do |ss|
    ss.vendored_frameworks = "BidOnApplovinMediationAdapter.xcframework"
    ss.dependency 'AppLovinSDK', '~> 11.7.1'
    ss.dependency 'BidOnMediationSdk/Core'
  end

  spec.subspec 'AdMob' do |ss|
    ss.vendored_frameworks = "BidOnAdMobMediationAdapter.xcframework"
    ss.dependency 'Google-Mobile-Ads-SDK', '~> 10.0.0'
    ss.dependency 'BidOnMediationSdk/Core'
  end
  
end
