FROM swift:5.8-jammy AS builder

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && apt-get -q update && \
    apt-get install -y -q \
    wget                  \
    curl                  \
    cmake                 \
    ninja-build           \
    python3               \
    zip                   \
    rsync                 \
    patchelf              \
    unzip

RUN rm -rf /var/lib/apt/lists/*
RUN ln -sf /usr/bin/python3 /usr/bin/python

RUN curl -fsSL https://github.com/NixOS/patchelf/releases/download/0.19.1/patchelf-0.19.1-x86_64.tar.gz | tar xz -C /usr/local ./bin/patchelf

RUN clang --version
RUN clang++ --version
RUN python --version

WORKDIR /root

COPY ./android-aarch64.json ./android-aarch64.json
COPY ./android-armv7.json ./android-armv7.json
COPY ./android-x86_64.json ./android-x86_64.json
COPY ./get-packages-and-swift-source.swift ./get-packages-and-swift-source.swift
COPY ./package-patches ./package-patches
COPY ./swift-android-ci.patch ./swift-android-ci.patch
COPY ./swift-android.patch ./swift-android.patch
COPY ./swift-android-16KB.patch ./swift-android-16KB.patch
COPY ./build/build_all.sh ./build_all.sh
COPY ./AndroidLibs ./AndroidLibs

RUN ./build_all.sh

FROM swift:jammy

COPY --from=builder /root/swift-release-android-aarch64-24-sdk.tar.xz .
COPY --from=builder /root/swift-release-android-armv7-24-sdk.tar.xz .
COPY --from=builder /root/swift-release-android-x86_64-24-sdk.tar.xz .
