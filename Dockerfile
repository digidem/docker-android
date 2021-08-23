FROM ubuntu:20.04

LABEL Description="This image provides a base Android development environment for React Native, and may be used to run tests."

USER root

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US:en


# set default build arguments
ARG SDK_VERSION=commandlinetools-linux-7302050_latest.zip
ARG BUCK_VERSION=2020.10.21.01
ARG NDK_VERSION=21.4.7075529
ARG NODE_VERSION=12.x
ARG WATCHMAN_VERSION=4.9.0

# set default environment variables, please don't remove old env for compatibilty issue
ENV ADB_INSTALL_TIMEOUT=10
ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_HOME=${ANDROID_HOME}
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV ANDROID_NDK=${ANDROID_HOME}/ndk/$NDK_VERSION
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

ENV PATH=${ANDROID_NDK}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:/opt/buck/bin/:${PATH}

# Install system dependencies
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
        libc++1-10 \
        libgl1 \
        libtcmalloc-minimal4 \
        libtool \
        make \
        openjdk-8-jdk-headless \
        openssh-client \
        patch \
        python3 \
        python3-distutils \
        rsync \
        ruby \
        ruby-dev \
        tzdata \
        unzip \
        sudo \
        ninja-build \
        zip \
    # for x86 emulators
    && apt-get install -qq -y \
      libxtst6 \
      libnss3-dev \
      libnspr4 \
      libxss1 \
      libasound2 \
      libatk-bridge2.0-0 \
      libgtk-3-0 \
      libgdk-pixbuf2.0-0 \
    && gem install bundler \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && rm -rf /var/lib/apt/lists/* \
    && sh -c 'echo "en_US.UTF-8 UTF-8" > /etc/locale.gen' \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8;

# install nodejs and yarn packages from nodesource
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
    && apt-get update -qq \
    && apt-get install -qq -y --no-install-recommends nodejs \
    && npm i -g yarn \
    && rm -rf /var/lib/apt/lists/*

# Full reference at https://dl.google.com/android/repository/repository2-1.xml
# download and unpack android
# workaround buck clang version detection by symlinking
RUN set -o xtrace \
    && curl -sS https://dl.google.com/android/repository/${SDK_VERSION} -o /tmp/sdk.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && unzip -q -d ${ANDROID_HOME}/cmdline-tools /tmp/sdk.zip \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/sdk.zip \
    && yes | sdkmanager --licenses \
    && wget -O /usr/bin/android-wait-for-emulator https://raw.githubusercontent.com/travis-ci/travis-cookbooks/master/community-cookbooks/android-sdk/files/default/android-wait-for-emulator \
    && chmod +x /usr/bin/android-wait-for-emulator \
    && mkdir -p /root/.android \
    && touch /root/.android/repositories.cfg \
    && yes | sdkmanager "platform-tools" \
        "emulator" \
        "platforms;android-29" \
        "build-tools;29.0.2" \
        "build-tools;28.0.3" \
        "cmake;3.18.1" \
        "system-images;android-21;google_apis;armeabi-v7a" \
        "system-images;android-28;default;x86_64" \
        "ndk;$NDK_VERSION"
