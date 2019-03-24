#!/bin/sh

echo "Copy 3rd framework start."
if [ -d "../ios-3rd-vendor/jrmf/AlipaySDK" ]; then
rm -rf ./framework/AlipaySDK
cp -rf ../ios-3rd-vendor/jrmf/AlipaySDK ./framework/
fi
if [ -d "../ios-3rd-vendor/jrmf/JrmfIMLib" ]; then
rm -rf ./framework/JrmfIMLib
cp -rf ../ios-3rd-vendor/jrmf/JrmfIMLib ./framework/
fi
if [ -d "../ios-3rd-vendor/ifly" ]; then
rm -rf ./framework/ifly
cp -rf ../ios-3rd-vendor/ifly ./framework/
fi
if [ -d "../ios-3rd-vendor/bqmm" ]; then
rm -rf ./framework/bqmm
cp -rf ../ios-3rd-vendor/bqmm ./framework/
fi
echo "Copy 3rd framework end."

