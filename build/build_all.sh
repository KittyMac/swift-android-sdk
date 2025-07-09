#!/bin/sh

create_sdk() {
    export SWIFT_TAG=$1
    export ANDROID_ARCH=$2
    export ANDROID_API_LEVEL=$3
    export ANDROID_NDK=$4
    
    # Run get-packages-and-swift-source.swift
    BUILD_SWIFT_PM=1 swift get-packages-and-swift-source.swift
    
    SDK_NAME=$(ls | grep swift-release-android-$ANDROID_ARCH)
    SDK=`pwd`/$SDK_NAME
    
    # Apply patches
    git apply swift-android.patch swift-android-ci.patch
        
    sed -i "s%/data/data/com.termux/files%$SDK%" $SDK/usr/lib/pkgconfig/sqlite3.pc
    sed -i "s%clang-path\", self.toolchain.cc,%clang-path\", os.path.join(toolchain_path, 'bin', 'clang'),%" swift/utils/swift_build_support/swift_build_support/products/swiftpm.py
    
    # sed -i "s%String(cString: getpass%\"fake\" //%" swiftpm/Sources/PackageRegistryTool/SwiftPackageRegistryTool.swift
    
    ./swift/utils/build-script -RA --skip-build-cmark --build-llvm=0 --android --android-ndk $ANDROID_NDK --android-arch $ANDROID_ARCH --android-api-level $ANDROID_API_LEVEL --build-swift-tools=0 --native-swift-tools-path=`pwd`/$SWIFT_TAG-ubuntu22.04/usr/bin --native-clang-tools-path=`pwd`/$SWIFT_TAG-ubuntu22.04/usr/bin --cross-compile-hosts=android-$ANDROID_ARCH --cross-compile-deps-path=$SDK --skip-local-build --build-swift-static-stdlib --xctest --skip-early-swift-driver --install-swift --install-libdispatch --install-foundation --install-xctest --install-destdir=$SDK --swift-install-components='clang-resource-dir-symlink;license;stdlib;sdk-overlay' --cross-compile-append-host-target-to-destdir=False -b -p --install-llbuild --sourcekit-lsp --skip-early-swiftsyntax || true
}

# Extract swift toolchain
tar xf ~/$SWIFT_TAG-ubuntu22.04.tar.gz

# Extract the android ndk
unzip ~/android-ndk-r25c.zip

create_sdk "swift-5.8.1-RELEASE" "aarch64" "24" "android-ndk-r25c"
