FROM ubuntu:22.04

# Arguments and environment variables
ARG BUILD_TOOLS_VERSION=34.0.0
ARG PLATFORM_VERSION=33
ARG COMMAND_LINE_VERSION=latest

# Installing necessary dependencies
RUN apt update && apt install -y curl git unzip openjdk-17-jdk wget

# Configuring the working directory and user to use
ARG USER=root
USER $USER
WORKDIR /home/$USER

# Prepare environment
ENV ANDROID_HOME /home/$USER/Android/sdk
ENV ANDROID_SDK_TOOLS $ANDROID_HOME/cmdline-tools/tools

# Creating Android directories
RUN mkdir -p $ANDROID_HOME
RUN mkdir -p $ANDROID_HOME/cmdline-tools
RUN mkdir -p /root/.android && touch /root/.android/repositories.cfg

# Download Android SDK
RUN wget -O commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
RUN unzip commandlinetools.zip && rm commandlinetools.zip
RUN mv cmdline-tools $ANDROID_SDK_TOOLS

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git

# Download sdk build tools and platform tools
WORKDIR $ANDROID_SDK_TOOLS/bin
RUN yes | ./sdkmanager --licenses
RUN ./sdkmanager "build-tools;${BUILD_TOOLS_VERSION}" "platform-tools" "platforms;android-${PLATFORM_VERSION}" "sources;android-${PLATFORM_VERSION}"
RUN ./sdkmanager --install "cmdline-tools;${COMMAND_LINE_VERSION}"

# Setup PATH environment variable
ENV PATH $PATH:/home/$USER/Android/sdk/platform-tools:$ANDROID_HOME/cmdline-tools/tools/bin:/home/$USER/flutter/bin

# # Verify the status licenses
RUN yes | flutter doctor --android-licenses

# # Start the adb daemon
# RUN adb start-servers
