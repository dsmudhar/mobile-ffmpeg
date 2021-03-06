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
LIB_NAME="soxr"
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
    -DCMAKE_CXX_COMPILER="$(get_toolchain_root)/bin/$CXX" \
    -DCMAKE_C_COMPILER="$(get_toolchain_root)/bin/$CC" \
    -DCMAKE_LINKER="$(get_toolchain_root)/bin/$LD" \
    -DCMAKE_AR="$(get_toolchain_root)/bin/$AR" \
    -DCMAKE_AS="$(get_toolchain_root)/bin/$AS" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
    -DBUILD_TESTS=0 \
    -DWITH_DEV_TRACE=0 \
    -DWITH_LSR_BINDINGS=0 \
    -DWITH_OPENMP=0 \
    -DWITH_PFFFT=1 \
    -DCMAKE_SYSTEM_PROCESSOR=$(get_cmake_target_processor) \
    -DBUILD_SHARED_LIBS=0 .. || exit 1

make -j$(get_cpu_count) || exit 1

# CREATE PACKAGE CONFIG MANUALLY
create_soxr_package_config "0.1.3"

make install || exit 1
