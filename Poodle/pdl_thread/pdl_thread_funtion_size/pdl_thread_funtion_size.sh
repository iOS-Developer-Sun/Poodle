#!/bin/sh

function pdl_thread () {
    arch=$1
    file=$2
    sym=$3
    out=$4

    path="${arch}/${file}"
    echo ${CONFIGURATION} ${arch} >> ${out}

    if [ -f $path ]; then
        nm -n -radix=d "${path}" | grep -A 1 ${sym} >> ${out}
        objdump -u "${path}" | grep -A 1 ${sym} >> ${out}
    fi
}

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

out="${scripts}/${CONFIGURATION}_${arch}.txt"

cd ${OBJECT_FILE_DIR_normal}

sym="______PDL_THREAD_FAKE_END_____"
file="pdl_thread.o"

if [[ $PLATFORM_NAME == "iphonesimulator" ]]; then
    arch="i386"
    out="${scripts}/pdl_thread_${CONFIGURATION}_${arch}.txt"
    pdl_thread ${arch} ${file} ${sym} ${out}

    arch="x86_64"
    out="${scripts}/pdl_thread_${CONFIGURATION}_${arch}.txt"
    pdl_thread ${arch} ${file} ${sym} ${out}
fi

if [[ $PLATFORM_NAME == "iphoneos" ]]; then
    arch="armv7"
    out="${scripts}/pdl_thread_${CONFIGURATION}_${arch}.txt"
    pdl_thread ${arch} ${file} ${sym} ${out}

    arch="arm64"
    out="${scripts}/pdl_thread_${CONFIGURATION}_${arch}.txt"
    pdl_thread ${arch} ${file} ${sym} ${out}
fi
