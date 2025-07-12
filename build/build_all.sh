#!/bin/sh

set -e

export SWIFT_VERSION="5.8"
export SWIFT_TAG="swift-$SWIFT_VERSION-RELEASE"
export ANDROID_ARCH="aarch64"
export ANDROID_API_LEVEL="24"
export ANDROID_NDK="android-ndk-r25c"
export SWIFT_UBUNTU_HOME=$5

# Download the correct swift toolchain
wget -q https://download.swift.org/swift-$SWIFT_VERSION-release/ubuntu2204/swift-$SWIFT_VERSION-RELEASE/swift-$SWIFT_VERSION-RELEASE-ubuntu22.04.tar.gz
tar -xvzf swift-$SWIFT_VERSION-RELEASE-ubuntu22.04.tar.gz
export SWIFT_UBUNTU_HOME=`pwd`/swift-$SWIFT_VERSION-RELEASE-ubuntu22.04


# Download the correct Android NDK
export ANDROID_NDK=`pwd`/android-ndk-r25c

echo "download https://dl.google.com/android/repository/android-ndk-r25c-linux.zip"
wget -q https://dl.google.com/android/repository/android-ndk-r25c-linux.zip
unzip android-ndk-r25c-linux.zip -d ./

python --version
swift --version

for arch in aarch64 armv7 x86_64; do
    
    # process each arch in a clean directory
    mkdir -p sdk_config && rsync -a --exclude=sdk_config ./ sdk_config/
    cd sdk_config
    
    # Run get-packages-and-swift-source.swift for this arch
    ANDROID_ARCH=$arch BUILD_SWIFT_PM=1 swift get-packages-and-swift-source.swift
    
    SDK_NAME=$(ls | grep swift-release-android-$arch)
    SDK=`pwd`/$SDK_NAME
    
    echo Building SDK "$SDK_NAME"
    
    # Apply all of this patches
    git apply swift-android.patch swift-android-ci.patch swift-android-16KB.patch
    
    sed -i "s%/data/data/com.termux/files%$SDK%" $SDK/usr/lib/pkgconfig/sqlite3.pc
    sed -i "s%clang-path\", self.toolchain.cc,%clang-path\", os.path.join(toolchain_path, 'bin', 'clang'),%" swift/utils/swift_build_support/swift_build_support/products/swiftpm.py
    
    sed -i "s%String(cString: getpass%\"fake\" //%" swiftpm/Sources/PackageRegistryTool/SwiftPackageRegistryTool.swift
    
    ./swift/utils/build-script -RA --skip-build-cmark --build-llvm=0 --android --android-ndk $ANDROID_NDK --android-arch $arch --android-api-level $ANDROID_API_LEVEL --build-swift-tools=0 --native-swift-tools-path=$SWIFT_UBUNTU_HOME/usr/bin --native-clang-tools-path=$SWIFT_UBUNTU_HOME/usr/bin --cross-compile-hosts=android-$arch --cross-compile-deps-path=$SDK --skip-local-build --build-swift-static-stdlib --xctest --skip-early-swift-driver --install-swift --install-libdispatch --install-foundation --install-xctest --install-destdir=$SDK --swift-install-components='clang-resource-dir-symlink;license;stdlib;sdk-overlay' --cross-compile-append-host-target-to-destdir=False -b -p --install-llbuild --sourcekit-lsp --skip-early-swiftsyntax

    cp $ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/$(echo $arch | sed "s/v7//")-linux-android*/libc++_shared.so $SDK/usr/lib
    patchelf --set-rpath \$ORIGIN $SDK/usr/lib/swift/android/libdispatch.so
    patchelf --set-rpath \$ORIGIN/../..:\$ORIGIN $SDK/usr/lib/swift/android/lib[FXs]*.so
    
    tar cJf ../$SDK_NAME.tar.xz $SDK_NAME
    
    cd ../
    
    rm -rf sdk_config
    
    ls -al
    
done

