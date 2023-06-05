FROM ubuntu:20.04

LABEL Description="This image provides a base Android development environment for React Native, and may be used to run tests."

USER root

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US:en

# set default build arguments
ARG SDK_VERSION=commandlinetools-linux-9477386_latest.zip
ARG ANDROID_BUILD_VERSION=31
ARG ANDROID_TOOLS_VERSION=30.0.3
ARG NDK_VERSION=24.0.8215888
ARG NODE_VERSION=16
ARG CMAKE_VERSION=3.18.1
ARG WATCHMAN_VERSION=4.9.0

# set default environment variables, please don't remove old env for compatibilty issue
ENV ADB_INSTALL_TIMEOUT=10
ENV ANDROID_HOME=/opt/android   
ENV ANDROID_SDK_HOME=${ANDROID_HOME}
ENV ANDROID_NDK=${ANDROID_HOME}/ndk/$NDK_VERSION
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV CMAKE_BIN_PATH=${ANDROID_HOME}/cmake/$CMAKE_VERSION/bin

ENV PATH=${CMAKE_BIN_PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_NDK}:${PATH}

# Install system dependencies for installing and running emulator
RUN apt update -qq && apt install -qq -y --no-install-recommends \
    apt-transport-https \
    autoconf \
    autotools-dev \
    build-essential \
    curl \
    file \
    gcc \
    git \
    g++ \
    gnupg2 \
    lcov \
    libc++1-10 \
    libgl1 \
    libglu1-mesa \
    libtcmalloc-minimal4 \
    libtool \
    locales \
    make \
    openjdk-11-jdk-headless \
    openssh-client \
    patch \
    python2 \
    python3 \
    python3-distutils \
    rsync \
    ruby \
    ruby-dev \
    tzdata \
    unzip \
    sudo \
    ninja-build \
    wget \
    zip \
    # Dev libraries requested by Hermes
    libicu-dev \
    # Emulator & video bridge dependencies
    libc6 \
    libdbus-1-3 \
    libfontconfig1 \
    libgcc1 \
    libpulse0 \
    libtinfo5 \
    libx11-6 \
    libxcb1 \
    libxdamage1 \
    libnss3 \
    libxcomposite1 \
    libxcursor1 \
    libxi6 \
    libxext6 \
    libxfixes3 \
    zlib1g \
    libgl1 \
    pulseaudio \
    socat \
    # for x86 emulators
    && apt-get install -qq -y \
    libxtst6 \
    libnspr4 \
    libxss1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libgdk-pixbuf2.0-0 \
    # python link required for NDK toolchain build to work
    && ln -s python3 /usr/bin/python \
    && gem install bundler \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && sh -c 'echo "en_US.UTF-8 UTF-8" > /etc/locale.gen' \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 

# install nodejs using n
RUN curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n \
    && bash n $NODE_VERSION \
    && rm n \
    && npm install -g n \
    && npm install -g yarn 

# download and unpack android
RUN curl -sS https://dl.google.com/android/repository/${SDK_VERSION} -o /tmp/sdk.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && unzip -q -d ${ANDROID_HOME}/cmdline-tools /tmp/sdk.zip \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/sdk.zip \
    && yes | sdkmanager --licenses \
    && wget -O /usr/bin/android-wait-for-emulator https://raw.githubusercontent.com/travis-ci/travis-cookbooks/master/community-cookbooks/android-sdk/files/default/android-wait-for-emulator \
    && chmod +x /usr/bin/android-wait-for-emulator \
    && yes | sdkmanager "platform-tools" \
    && yes | sdkmanager "emulator" \
    && yes | sdkmanager \
    "platforms;android-$ANDROID_BUILD_VERSION" \
    "build-tools;$ANDROID_TOOLS_VERSION" \
    "cmake;$CMAKE_VERSION" \
    "system-images;android-21;google_apis;armeabi-v7a" \
    "system-images;android-28;default;x86_64" \
    "ndk;$NDK_VERSION" \
    && chmod 777 -R /opt/android
