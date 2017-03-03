
build_targets=($1)
build_SDKS=($2)

BULID_PATH="${BUILD_DIR}/${CONFIGURATION}"

UNIVERSAL_DIR="${BULID_PATH}-universal"
IPHONE_DIR="${BULID_PATH}-iphoneos"
SIMULATOR_DIR="${BULID_PATH}-iphonesimulator"

// CLEAR BULID directory
rm -rf $UNIVERSAL_DIR
rm -rf $IPHONE_DIR
rm -rf $SIMULATOR_DIR

mkdir -p $UNIVERSAL_DIR

for bulid_target in ${build_targets[*]}
do
xcodebuild  OTHER_CFLAGS="-fembed-bitcode" -target $bulid_target ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos  BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build
xcodebuild  OTHER_CFLAGS="-fembed-bitcode" -target $bulid_target ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphonesimulator ARCHS='i386 x86_64' VALID_ARCHS='i386 x86_64' BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build
echo "bulid finished and begin lipo"
lipo -create -output "${UNIVERSAL_DIR}/lib${bulid_target}.a" "${IPHONE_DIR}/lib${bulid_target}.a" "${SIMULATOR_DIR}/lib${bulid_target}.a"
done

i=0
for bulid_target in ${build_targets[*]}
do
sdk_path=${build_SDKS[i]}
COPYTO_DIR="${PROJECT_DIR}/../RedpacketSDKS/${sdk_path}/lib"
rm -rf $COPYTO_DIR
mkdir -p $COPYTO_DIR

cp -rf "${UNIVERSAL_DIR}/lib${bulid_target}.a" "${COPYTO_DIR}/"
i=`expr $i+1`
done
