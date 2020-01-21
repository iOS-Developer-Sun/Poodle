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

pdl_iphoneos_build="${BUILD_DIR}/${CONFIGURATION}-iphoneos"
pdl_iphonesimulator_build="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator"

pdl_iphoneos_library="${pdl_iphoneos_build}"/lib"${TARGETNAME}".a
pdl_iphonesimulator_library="${pdl_iphonesimulator_build}"/lib"${TARGETNAME}".a
pdl_universal_library=lib"${TARGETNAME}".a

cp "${pdl_iphoneos_build}/${TARGETNAME}"/*.h .
if [ -f "${pdl_iphoneos_library}" ] && [ -f "${pdl_iphonesimulator_library}" ] ; then
    lipo -create "${pdl_iphoneos_library}" "${pdl_iphonesimulator_library}" -output "${pdl_universal_library}"
    libtool -static -D "${pdl_universal_library}" -o "${pdl_universal_library}" 2> /dev/null
fi
