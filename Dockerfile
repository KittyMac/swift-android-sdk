FROM swift:5.8-jammy

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && apt-get -q update && \
    apt-get install -y    \
    wget                  \
    curl                  \
    build-essential       \
    cmake                 \
    file                  \
    git                   \
    icu-devtools          \
    libc++-15-dev         \
    libc++abi-15-dev      \
    libcurl4-openssl-dev  \
    libedit-dev           \
    libicu-dev            \
    libncurses5-dev       \
    libpython3-dev        \
    libsqlite3-dev        \
    libxml2-dev           \
    ninja-build           \
    pkg-config            \
    python2               \
    python-six            \
    python2-dev           \
    python3-six           \
    python3-pip           \
    python3-distutils     \
    python3-pkg-resources \
    python3-psutil        \
    rsync                 \
    swig                  \
    systemtap-sdt-dev     \
    tzdata                \
    uuid-dev              \
    patchelf              \
    zip

RUN rm -rf /var/lib/apt/lists/*

WORKDIR /root

COPY ./android-aarch64.json ./android-aarch64.json
COPY ./android-armv7.json ./android-armv7.json
COPY ./android-x86_64.json ./android-x86_64.json
COPY ./get-packages-and-swift-source.swift ./get-packages-and-swift-source.swift
COPY ./package-patches ./package-patches
COPY ./swift-android-ci.patch ./swift-android-ci.patch
COPY ./swift-android.patch ./swift-android.patch
COPY ./build/build_all.sh ./build_all.sh
COPY ./build/swift-5.8.1-RELEASE-ubuntu22.04.tar.gz ./swift-5.8.1-RELEASE-ubuntu22.04.tar.gz
COPY ./build/android-ndk-r25c.zip ./android-ndk-r25c.zip

RUN ./build_all.sh



