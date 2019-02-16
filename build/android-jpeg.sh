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
LIB_NAME="jpeg"
set_toolchain_clang_paths ${LIB_NAME}

# PREPARING FLAGS
TARGET_HOST=$(get_target_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

if [ -d "build" ]; then
    rm -rf build
fi

mkdir build || exit 1
cd build || exit 1

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
    -DCMAKE_CXX_COMPILER="$(get_toolchain_root)/bin/$CXX" \
    -DCMAKE_LINKER="$(get_toolchain_root)/bin/$LD" \
    -DCMAKE_AR="$(get_toolchain_root)/bin/$AR" \
    -DCMAKE_AS="$(get_toolchain_root)/bin/$AS" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
    -DENABLE_STATIC=1 \
    -DENABLE_SHARED=0 \
    -DWITH_JPEG8=1 \
    -DWITH_SIMD=1 \
    -DWITH_TURBOJPEG=0 \
    -DWITH_JAVA=0 \
    -DCMAKE_SYSTEM_PROCESSOR=$(get_cmake_target_processor) .. || exit 1

make -j$(get_cpu_count) || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp ${BASEDIR}/src/${LIB_NAME}/build/pkgscripts/libjpeg.pc ${INSTALL_PKG_CONFIG_DIR}

make install || exit 1
