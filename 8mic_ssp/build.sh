#!/bin/sh

# ./build.sh [arm | arm64]
if [ "$1" = "arm" ]; then
    echo "---------start build uni ssp hal armeabi-v7a-------"
    BUILD_ABI="armeabi-v7a"
elif [ "$1" = "arm64" ] ; then
    echo "---------start build uni ssp hal arm64-v8a-------"
    BUILD_ABI="arm64-v8a"
else
    echo "---------start build uni ssp hal armeabi-v7a arm64-v8a-------"
    BUILD_ABI="armeabi-v7a arm64-v8a"
fi

NDK=/home/unisound/code/android-ndk-r23c
TOOLCHAIN=$NDK/build/cmake/android.toolchain.cmake
PLATFORM=21

OUTPUT_DIR=build
mkdir $OUTPUT_DIR

cp_libs() {
  ABI=$1

  if [ ! -d "output" ]; then
    mkdir output
  fi

  if [ ! -d "output/config" ]; then
    mkdir output/config
  fi

  if [ -d "output/$ABI" ]; then
    rm -rf output/"$ABI"
  fi
  mkdir -p output/"$ABI"

  cp ssp_hal/config/*.* output/config

  cp ssp_hal/libs/"$ABI"/*.so output/"$ABI"

  cp $OUTPUT_DIR/libs/"$ABI"/*.so output/"$ABI"
}

# 编译逻辑
for ABI in $BUILD_ABI; do
  echo "---------start build $ABI-------"
  cmake \
      -D CMAKE_SYSTEM_NAME=Android \
      -D CMAKE_SYSTEM_VERSION=$PLATFORM \
      -D ANDROID_PLATFORM=android-$PLATFORM \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_TOOLCHAIN_FILE=$TOOLCHAIN \
      -D CMAKE_ANDROID_NDK=$NDK \
      -D CMAKE_ANDROID_ARCH_ABI="$ABI" \
      -D ANDROID_ABI="$ABI" \
      -S . \
      -B $OUTPUT_DIR
  cmake --build $OUTPUT_DIR -- -j4
  echo "---------build $ABI finished-------"

  cp_libs "$ABI"
done

echo "---------remove build folder $OUTPUT_DIR-------"
rm -rf $OUTPUT_DIR