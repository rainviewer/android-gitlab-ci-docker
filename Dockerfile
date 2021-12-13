FROM openjdk:11-jdk

ENV ANDROID_COMPILE_SDK "31"
ENV ANDROID_BUILD_TOOLS "31.0.0"
ENV ANDROID_SDK_TOOLS   "7583922"
ENV EMULATOR_VERSION    "31"
ENV ANDROID_HOME        "/android-home"

ENV PATH "$ANDROID_HOME/cmdline-tools/emulator/:$ANDROID_HOME/cmdline-tools/tools/bin/:$ANDROID_HOME/cmdline-tools/bin/:$PATH"

RUN apt-get -qq update \
	&& apt-get -y install wget tar unzip lib32stdc++6 lib32z1 \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Command-line tools
RUN install -d $ANDROID_HOME \
	&& wget --output-document=$ANDROID_HOME/cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip \
	&& cd $ANDROID_HOME \
	&& unzip -d . cmdline-tools.zip \
	&& rm -v $ANDROID_HOME/cmdline-tools.zip

# Licenses
RUN mkdir -p $ANDROID_HOME/licenses/ \
	&& echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_HOME/licenses/android-sdk-license \
	&& echo "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > $ANDROID_HOME/licenses/android-sdk-preview-license \
	&& yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses || true

# SDK
RUN sdkmanager --sdk_root=${ANDROID_HOME} --update \
	# && sdkmanager --sdk_root=${ANDROID_HOME} "add-ons;addon-google_apis-google-24" \
	&& sdkmanager --sdk_root=${ANDROID_HOME} "platforms;android-${ANDROID_COMPILE_SDK}" \
	&& sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools" \
	&& sdkmanager --sdk_root=${ANDROID_HOME} "build-tools;${ANDROID_BUILD_TOOLS}" \
	# && sdkmanager --sdk_root=${ANDROID_HOME} "extras;android;m2repository" \
	# && sdkmanager --sdk_root=${ANDROID_HOME} "extras;google;m2repository" \
	&& sdkmanager --sdk_root=${ANDROID_HOME} "extras;google;google_play_services"

# Fix issue with 31.0.0 build-tools
# https://stackoverflow.com/questions/68387270/android-studio-error-installed-build-tools-revision-31-0-0-is-corrupted
RUN  cd $ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS \
		&& cp -R d8 dx \
  		&& cd lib  \
  		&& cp d8.jar dx.jar
