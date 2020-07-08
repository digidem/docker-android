FROM reactnativecommunity/react-native-android:2020-6-4

LABEL Description="Android image for running e2e tests with KVM."

# Install packages
RUN apt-get -qqy update && \
    apt-get -qqy --no-install-recommends install libc++1 \
    curl ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Open ADB port
EXPOSE 5555
EXPOSE 5556

# Install system images
ENV ARCH=x86_64 \
    TARGET=default \
    EMULATOR_API_LEVEL=28

# API 28 system image
RUN sdkmanager --install "system-images;android-${EMULATOR_API_LEVEL};${TARGET};${ARCH}" \
    "platforms;android-${EMULATOR_API_LEVEL}" \
    "emulator"
