#!/bin/sh

lib=$1
filename=`basename $lib`
mkdir -p tmp
#echo $lib
cp $lib tmp/$filename
pushd tmp > /dev/null
archs=`lipo -archs $filename`
#echo $archs
count=`echo $archs | wc -w`
#echo $count
if [ "$count" -gt 1 ]
then
    for arch in $archs
    do
        rm -rf *.o
#        echo $arch
        lipo -thin $arch $filename -o $arch
        ar -x $arch
        for file in *.o
        do
            vtool -remove-build-version iossim $file -output $file
            vtool -remove-build-version ios $file -output $file
        done
        libtool -static -D *.o -o $arch 2> /dev/null
    done
    lipo -create $archs -o $filename
elif [ "$count" -eq 1 ]
then
    rm -rf *.o
    ar -x $filename
    for file in *.o
    do
        vtool -remove-build-version iossim $file -output $file
        vtool -remove-build-version ios $file -output $file
    done
    libtool -static -D *.o -o $filename 2> /dev/null
fi
popd > /dev/null
cp -f tmp/$filename $lib
rm -rf tmp
