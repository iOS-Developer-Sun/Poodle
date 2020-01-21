#!/bin/sh

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# iphoneos iphonesimulator
if [[ ${PLATFORM_NAME} != "iphoneos" ]] ; then
    exit 0
fi

#${PROJECT_TEMP_DIR} /Users/Poodle/Library/Developer/Xcode/DerivedData/PoodleLibrary-grmuqrhxvabwmrhhaosuzeeemuqx/Build/Intermediates.noindex/PoodleLibrary.build

#${CONFIGURATION} Debug

#${VALID_ARCHS} "arm64 arm64e armv7 armv7s"
#${OBJECT_FILE_DIR_normal} /Users/Poodle/Library/Developer/Xcode/DerivedData/PoodleLibrary-grmuqrhxvabwmrhhaosuzeeemuqx/Build/Intermediates.noindex/PoodleLibrary.build/Debug-iphoneos/PoodleLibrary.build/Objects-normal
#${TARGETNAME} PoodleLibrary

pdl_iphoneos_archs="armv7 armv7s arm64 arm64e"
pdl_iphonesimulator_archs="i386 x86_64"

pdl_iphoneos_object="${PROJECT_TEMP_DIR}/${CONFIGURATION}-iphoneos/${TARGETNAME}.build/Objects-normal"
pdl_iphonesimulator_object="${PROJECT_TEMP_DIR}/${CONFIGURATION}-iphonesimulator/${TARGETNAME}.build/Objects-normal"

echo "pdl_iphoneos_object ${pdl_iphoneos_object}"
echo "pdl_iphonesimulator_object ${pdl_iphonesimulator_object}"

#open "${pdl_iphoneos_object}"
#open "${pdl_iphonesimulator_object}"

#for i in $pdl_iphoneos_archs;
#do
#pdl_iphoneos_object_arch="${pdl_iphoneos_object}/$i"
#open "${pdl_iphoneos_object_arch}"
#done

for i in $pdl_iphonesimulator_archs;
do
pdl_iphonesimulator_object_arch="${pdl_iphonesimulator_object}/$i"
#open "${pdl_iphonesimulator_object_arch}"
done
