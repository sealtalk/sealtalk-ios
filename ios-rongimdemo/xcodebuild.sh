#!/bin/sh

echo "Copy 3rd framework start."
if [ -d "../ios-3rd-vendor/jrmf/AlipaySDK" ]; then
cp -rf ../ios-3rd-vendor/jrmf/AlipaySDK ./framework/
fi
if [ -d "../ios-3rd-vendor/jrmf/JrmfIMLib" ]; then
cp -rf ../ios-3rd-vendor/jrmf/JrmfIMLib ./framework/
fi
if [ -d "../ios-3rd-vendor/ifly" ]; then
cp -rf ../ios-3rd-vendor/ifly ./framework/
fi
if [ -d "../ios-3rd-vendor/bqmm" ]; then
cp -rf ../ios-3rd-vendor/bqmm ./framework/
fi
echo "Copy 3rd framework end."
