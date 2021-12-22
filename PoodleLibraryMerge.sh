#!/bin/sh

if [[ $CONFIGURATION != "Release" ]]; then
    echo "Not Release."
    exit 0
fi

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "${scripts}/PoodleLibrary/"
mkdir -p "${TARGETNAME}"
cd "${TARGETNAME}"
rm -rf *

# iOS
pdl_iphoneos_build="${BUILD_DIR}/${CONFIGURATION}-iphoneos"
pdl_iphonesimulator_build="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator"

pdl_iphoneos_library="${pdl_iphoneos_build}"/lib"${TARGETNAME}".a
pdl_iphonesimulator_library="${pdl_iphonesimulator_build}"/lib"${TARGETNAME}".a
pdl_universal_library=ios/lib"${TARGETNAME}".a

cp "${pdl_iphoneos_build}/${TARGETNAME}"/*.h . 2>/dev/null

if [ -f "${pdl_iphoneos_library}" ] && [ -f "${pdl_iphonesimulator_library}" ] ; then
    mkdir ios
    lipo -create "${pdl_iphoneos_library}" "${pdl_iphonesimulator_library}" -output "${pdl_universal_library}"
    libtool -static -D "${pdl_universal_library}" -o "${pdl_universal_library}" 2> /dev/null
fi

# macOS
pdl_macos_build="${BUILD_DIR}/${CONFIGURATION}"
pdl_macos_library="${pdl_macos_build}"/lib"${TARGETNAME}".a
pdl_universal_library=macos/lib"${TARGETNAME}".a

if [ -f "${pdl_macos_library}" ] ; then
    mkdir macos
    cp "${pdl_macos_library}" "${pdl_universal_library}"
fi
