#!/bin/bash
set -e
set -x

# Set directory
SCRIPTPATH=$(realpath .)
BOOST_VERSION=1.85.0

# Clone boost-iosx if not exists
BOOST_IOSX_DIR=$SCRIPTPATH/boost-iosx
if [ ! -d "$BOOST_IOSX_DIR" ]; then
    echo "Cloning boost-iosx..."
    git clone --branch ${BOOST_VERSION} https://github.com/apotocki/boost-iosx.git
fi

cd $BOOST_IOSX_DIR

# Clean previous builds
rm -rf build output frameworks

# Build Boost for iOS
# Use -p to specify platforms: ios (device), iossim-arm64, iossim-x86_64
# Use -l to specify libraries: system,program_options
scripts/build.sh -p=ios,iossim-arm64,iossim-x86_64 -l=system,program_options

# Copy the outputs to our lib structure
echo "Copying Boost libraries to output directories..."

FRAMEWORKS_DIR=$BOOST_IOSX_DIR/frameworks

# Copy device libraries (arm64)
echo "Copying iOS device libraries..."
mkdir -p $SCRIPTPATH/lib/iphoneos/arm64
cp $FRAMEWORKS_DIR/boost_system.xcframework/ios-arm64/libboost_system.a \
   $SCRIPTPATH/lib/iphoneos/arm64/
cp $FRAMEWORKS_DIR/boost_program_options.xcframework/ios-arm64/libboost_program_options.a \
   $SCRIPTPATH/lib/iphoneos/arm64/

# Extract simulator libraries from fat binary
echo "Extracting simulator libraries..."

# iOS Simulator (arm64)
mkdir -p $SCRIPTPATH/lib/iphonesimulator/arm64
lipo $FRAMEWORKS_DIR/boost_system.xcframework/ios-arm64_x86_64-simulator/libboost_system.a \
     -thin arm64 -output $SCRIPTPATH/lib/iphonesimulator/arm64/libboost_system.a
lipo $FRAMEWORKS_DIR/boost_program_options.xcframework/ios-arm64_x86_64-simulator/libboost_program_options.a \
     -thin arm64 -output $SCRIPTPATH/lib/iphonesimulator/arm64/libboost_program_options.a

# iOS Simulator (x86_64)
mkdir -p $SCRIPTPATH/lib/iphonesimulator/x86_64
lipo $FRAMEWORKS_DIR/boost_system.xcframework/ios-arm64_x86_64-simulator/libboost_system.a \
     -thin x86_64 -output $SCRIPTPATH/lib/iphonesimulator/x86_64/libboost_system.a
lipo $FRAMEWORKS_DIR/boost_program_options.xcframework/ios-arm64_x86_64-simulator/libboost_program_options.a \
     -thin x86_64 -output $SCRIPTPATH/lib/iphonesimulator/x86_64/libboost_program_options.a

# Copy Boost headers
echo "Copying Boost headers..."
mkdir -p $SCRIPTPATH/include
cp -R $FRAMEWORKS_DIR/Headers/boost $SCRIPTPATH/include/

echo "Boost build complete!"
echo "Headers: ${SCRIPTPATH}/include/boost"
echo "Libraries: ${SCRIPTPATH}/lib/"
