#!/bin/sh

function pdl_thread () {
    arch=$1
    file=$2
    sym=$3
    out=$4

    path="${arch}/${file}"
    echo ${CONFIGURATION} ${arch} > ${out}

    if [ -f $path ]; then
        nm -n -radix=d "${path}" | grep -A 1 ${sym} >> ${out}
        objdump -u "${path}" | grep -A 1 ${sym} >> ${out}
        objdump -df=${sym} -d $path >> ${out}
    fi
}

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

folder="${scripts}/pdl_thread_funtion_size"

cd ${OBJECT_FILE_DIR_normal}

sym="______PDL_THREAD_FAKE_END_____"
file="pdl_thread.o"

if [[ $PLATFORM_NAME == "iphonesimulator" ]]; then
    arch="i386"
    out="${folder}/${CONFIGURATION}_${arch}.txt"
    pdl_thread ${arch} ${file} ${sym} ${out}

    arch="x86_64"
    out="${folder}/${CONFIGURATION}_${arch}.txt"
    pdl_thread ${arch} ${file} ${sym} ${out}
fi

if [[ $PLATFORM_NAME == "iphoneos" ]]; then
    arch="armv7"
    out="${folder}/${CONFIGURATION}_${arch}.txt"
    pdl_thread ${arch} ${file} ${sym} ${out}

    arch="arm64"
    out="${folder}/${CONFIGURATION}_${arch}.txt"
    pdl_thread ${arch} ${file} ${sym} ${out}
fi
