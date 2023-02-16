#!/bin/sh

# ----------------------------------
# ENVIROMENT VARIABLES
# ----------------------------------
SCHEMES=( 
    "BidOnMediationSdk"
    "BidOnBidMachineMediationAdapter"
    "BidOnApplovinMediationAdapter"
    "BidOnAdMobMediationAdapter"
)

start=`date +%s`
# ----------------------------------
# CLEAR TEMPORARY AND RELEASE PATHS
# ----------------------------------
function prepare {
    rm -rf "./build"
    rm -rf "./release"
}

# ----------------------------------
# BUILD PLATFORM SPECIFIC FRAMEWORKS
# ----------------------------------
function xcframework {
    # iOS devices
    xcodebuild archive \
        -workspace "./BidOnMediationSdk.xcworkspace" \
        -scheme "BuildTarget" \
        -archivePath "./build/ios.xcarchive" \
        -sdk iphoneos \
        VALID_ARCHS="arm64" \
        GCC_GENERATE_DEBUGGING_SYMBOLS=NO \
        STRIP_INSTALLED_PRODUCT=YES \
        LINK_FRAMEWORKS_AUTOMATICALLY=NO \
                ONLY_ACTIVE_ARCH=NO \
                DEPLOYMENT_POSTPROCESSING=YES \
                MACH_O_TYPE=staticlib \
                IPHONEOS_DEPLOYMENT_TARGET=12.0 \
                DEBUG_INFORMATION_FORMAT="dwarf" \
        SKIP_INSTALL=NO | xcpretty

    # iOS simulator
    xcodebuild archive \
        -workspace "./BidOnMediationSdk.xcworkspace" \
        -scheme "BuildTarget" \
        -archivePath "./build/ios_sim.xcarchive" \
        -sdk iphonesimulator \
        VALID_ARCHS="x86_64 arm64" \
        GCC_GENERATE_DEBUGGING_SYMBOLS=NO \
        STRIP_INSTALLED_PRODUCT=YES \
        LINK_FRAMEWORKS_AUTOMATICALLY=NO \
                ONLY_ACTIVE_ARCH=NO \
                DEPLOYMENT_POSTPROCESSING=YES \
                MACH_O_TYPE=staticlib \
                IPHONEOS_DEPLOYMENT_TARGET=12.0 \
                DEBUG_INFORMATION_FORMAT="dwarf" \
        SKIP_INSTALL=NO | xcpretty  
}


# -------------------
# PACKAGE XCFRAMEWORK
# -------------------

function package {
    scheme="$1"
    xcodebuild -create-xcframework \
        -framework "./build/ios.xcarchive/Products/Library/Frameworks/$scheme.framework" \
        -framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/$scheme.framework" \
        -output "./release/$scheme.xcframework"
}

# ----------------------------------
# COPY INFO
# ----------------------------------

function copyInfo {
    cp "./Specs/LICENSE" "./release/LICENSE"
    cp "./Specs/CHANGELOG.md" "./release/CHANGELOG.md"
}

# ----------------------------------
# COMPRESS
# ----------------------------------
function compress {
    echo "🗜 Compress packages"
    cd "./release"
    zip -r "BidOnMediationSdk.zip" * > /dev/null
    cd -
}

prepare
xcframework
for scheme in ${SCHEMES[@]}; do
    package "$scheme"
done

copyInfo
compress

end=`date +%s`
runtime=$((end-start))
echo "🚀 Build finished at: $runtime seconds"
