#!/bin/bash

if [[ -z ${ANDROID_NDK_ROOT} ]]; then
    echo -e "(*) ANDROID_NDK_ROOT not defined\n"
    exit 1
fi

if [[ -z ${ARCH} ]]; then
    echo -e "(*) ARCH not defined\n"
    exit 1
fi

if [[ -z ${API} ]]; then
    echo -e "(*) API not defined\n"
    exit 1
fi

if [[ -z ${BASEDIR} ]]; then
    echo -e "(*) BASEDIR not defined\n"
    exit 1
fi

# ENABLE COMMON FUNCTIONS
. ${BASEDIR}/build/android-common.sh

# PREPARING PATHS & DEFINING ${INSTALL_PKG_CONFIG_DIR}
LIB_NAME="libwebp"
set_toolchain_clang_paths ${LIB_NAME}

# PREPARING FLAGS
TARGET_HOST=$(get_target_host)
CFLAGS=$(get_cflags ${LIB_NAME})
CXXFLAGS=$(get_cxxflags ${LIB_NAME})
LDFLAGS=$(get_ldflags ${LIB_NAME})

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

if [ -d "build" ]; then
    rm -rf build
fi

mkdir build;
cd build

# OVERRIDING INCLUDE PATH ORDER
CFLAGS="-I$(get_prefix_root)/giflib/include \
-I$(get_prefix_root)/jpeg/include \
-I$(get_prefix_root)/libpng/include \
-I$(get_prefix_root)/tiff/include $CFLAGS"

cmake -Wno-dev \
    -DCMAKE_VERBOSE_MAKEFILE=0 \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_SYSROOT="$(get_toolchain_root)/sysroot" \
    -DCMAKE_FIND_ROOT_PATH="$(get_toolchain_root)/sysroot" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$(get_prefix_root)/${LIB_NAME}" \
    -DCMAKE_SYSTEM_NAME=Generic \
    -DCMAKE_C_COMPILER="$(get_toolchain_root)/bin/$CC" \
    -DCMAKE_LINKER="$(get_toolchain_root)/bin/$LD" \
    -DCMAKE_AR="$(get_toolchain_root)/bin/$AR" \
    -DCMAKE_AS="$(get_toolchain_root)/bin/$AS" \
    -DGIF_INCLUDE_DIR="$(get_prefix_root)/giflib/include" \
    -DJPEG_INCLUDE_DIR="$(get_prefix_root)/jpeg/include" \
    -DJPEG_LIBRARY="$(get_prefix_root)/jpeg/lib" \
    -DPNG_PNG_INCLUDE_DIR="$(get_prefix_root)/libpng/include" \
    -DPNG_LIBRARY="$(get_prefix_root)/libpng/lib" \
    -DTIFF_INCLUDE_DIR="$(get_prefix_root)/tiff/include" \
    -DTIFF_LIBRARY="$(get_prefix_root)/tiff/lib" \
    -DZLIB_INCLUDE_DIR="$(get_toolchain_root)/sysroot/usr/include" \
    -DZLIB_LIBRARY="${ANDROID_NDK_ROOT}/platform/android-${API}/arch-$(get_target_build)/usr/lib" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
    -DGLUT_INCLUDE_DIR= \
    -DGLUT_cocoa_LIBRARY= \
    -DGLUT_glut_LIBRARY= \
    -DOPENGL_INCLUDE_DIR= \
    -DSDLMAIN_LIBRARY= \
    -DSDL_INCLUDE_DIR= \
    -DWEBP_BUILD_CWEBP=0 \
    -DWEBP_BUILD_DWEBP=0 \
    -DWEBP_BUILD_EXTRAS=0 \
    -DWEBP_BUILD_GIF2WEBP=0 \
    -DWEBP_BUILD_IMG2WEBP=0 \
    -DWEBP_BUILD_WEBPMUX=0 \
    -DWEBP_BUILD_WEBPINFO=0 \
    -DCMAKE_SYSTEM_PROCESSOR=$(get_cmake_target_processor) \
    -DBUILD_SHARED_LIBS=0 .. || exit 1

make -j$(get_cpu_count) || exit 1

# CREATE PACKAGE CONFIG MANUALLY
create_libwebp_package_config "1.0.1"

make install || exit 1
