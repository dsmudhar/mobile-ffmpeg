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
LIB_NAME="tesseract"
set_toolchain_clang_paths ${LIB_NAME}

# PREPARING FLAGS
TARGET_HOST=$(get_target_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

# RECONFIGURING IF REQUESTED
if [[ ! -f ${BASEDIR}/src/${LIB_NAME}/configure ]] || [[ ${RECONF_tesseract} -eq 1 ]]; then
    autoreconf_library ${LIB_NAME}
fi

export LEPTONICA_CFLAGS="-I$(get_prefix_root)/leptonica/include/leptonica"
export LEPTONICA_LIBS="-L$(get_prefix_root)/leptonica/lib -llept"

# MANUALLY SET ENDIANNESS
export ac_cv_c_bigendian=no

./configure \
    --prefix=$(get_prefix_root)/${LIB_NAME} \
    --with-pic \
    --with-sysroot=$(get_toolchain_root)/sysroot \
    --enable-static \
    --disable-shared \
    --disable-fast-install \
    --disable-debug \
    --disable-graphics \
    --disable-cube \
    --disable-tessdata-prefix \
    --disable-largefile \
    --host=${TARGET_HOST} || exit 1

${SED_INLINE} 's/\-lrt//g' ${BASEDIR}/src/${LIB_NAME}/api/Makefile

make -j$(get_cpu_count) || exit 1

# CREATE PACKAGE CONFIG MANUALLY
create_tesseract_package_config "3.05.02"

make install || exit 1
