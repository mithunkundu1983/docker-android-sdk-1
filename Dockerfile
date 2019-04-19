FROM openjdk:8

MAINTAINER Mithun Kundu <mithunkundu1983@gmail.com>

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    apt-get install -yq libc6 libstdc++6 zlib1g libncurses5 build-essential libssl-dev ruby ruby-dev --no-install-recommends && \
    apt-get install -yq locales ca-certificates nano rsync sudo zip git wget libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 python curl psmisc && \
    apt-get clean
    
RUN gem install bundler

# Download and untar Android SDK tools
RUN mkdir -p /usr/local/android-sdk-linux && \
    wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -O tools.zip && \
    unzip tools.zip -d /usr/local/android-sdk-linux && \
    rm tools.zip

# Set environment variable
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV PATH ${ANDROID_HOME}/tools:$ANDROID_HOME/platform-tools:$PATH

# Make license agreement
RUN mkdir $ANDROID_HOME/licenses && \
    echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > $ANDROID_HOME/licenses/android-sdk-license && \
    echo d56f5187479451eabf01fb78af6dfcb131a6481e >> $ANDROID_HOME/licenses/android-sdk-license && \
    echo 24333f8a63b6825ea9c5514f83c2829b004d1fee >> $ANDROID_HOME/licenses/android-sdk-license && \
    echo 84831b9409646a918e30573bab4c9c91346d8abd > $ANDROID_HOME/licenses/android-sdk-preview-license

# Update and install using sdkmanager
RUN $ANDROID_HOME/tools/bin/sdkmanager "tools" "platform-tools" && \
    $ANDROID_HOME/tools/bin/sdkmanager "build-tools;28.0.3" "build-tools;27.0.3" && \
    $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-28" "platforms;android-27" && \
    $ANDROID_HOME/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;m2repository"

# Updating everything again
RUN $ANDROID_HOME/tools/bin/sdkmanager --update

#accepting licenses
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses
RUN $ANDROID_HOME/tools/bin/sdkmanager --version
##################
# Speeding up android builds
# Gradle will pick these properties when running
##################
RUN mkdir ~/.gradle
RUN echo "org.gradle.daemon=true" >> ~/.gradle/gradle.properties
RUN echo "org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8" >> ~/.gradle/gradle.properties
RUN echo "org.gradle.parallel=true" >> ~/.gradle/gradle.properties
RUN echo "org.gradle.configureondemand=true" >> ~/.gradle/gradle.properties
RUN echo "android.builder.sdkDownload=true" >> ~/.gradle/gradle.properties
RUN rm -rf /var/lib/apt/lists/*
