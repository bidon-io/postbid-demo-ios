platform :ios, '12.0'
install! 'cocoapods', :deterministic_uuids => false, :warn_for_multiple_pod_sources => false

workspace 'BidOnMediationSdk.xcworkspace'

$BDMVersion = '~> 2.0.0.0'
$AppLovinVersion = '~> 11.7.1'
$GoogleVersion = '~> 10.0.0'

def bidmachine
  pod "BidMachine", $BDMVersion
end

def applovin 
  pod 'AppLovinSDK', $AppLovinVersion
end

def google 
  pod 'Google-Mobile-Ads-SDK', $GoogleVersion
end

target 'Sample' do
project 'Sample/Sample.xcodeproj'
  applovin
  bidmachine
  google
end

target 'BidOnBidMachineMediationAdapter' do
  project 'BidOnMediationAdapters/BidOnMediationAdapters.xcodeproj'
  bidmachine
end

target 'BidOnApplovinMediationAdapter' do
  project 'BidOnMediationAdapters/BidOnMediationAdapters.xcodeproj'
  applovin
end

target 'BidOnAdMobMediationAdapter' do
  project 'BidOnMediationAdapters/BidOnMediationAdapters.xcodeproj'
  google
end

# Post install configuration
post_install do |installer|
  project = installer.pods_project
  project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end


