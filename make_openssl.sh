#!/bin/bash
set -e
set -x

# Set directory
SCRIPTPATH=$(realpath .)
OPENSSL_VERSION=3.0.15
OPENSSL_DIR=$SCRIPTPATH/openssl-${OPENSSL_VERSION}

# Download OpenSSL if not exists
if [ ! -d "$OPENSSL_DIR" ]; then
    echo "Downloading OpenSSL ${OPENSSL_VERSION}..."
    curl -L https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz -o openssl-${OPENSSL_VERSION}.tar.gz
    tar xzf openssl-${OPENSSL_VERSION}.tar.gz
    rm openssl-${OPENSSL_VERSION}.tar.gz
fi

# iOS deployment target
IOS_DEPLOYMENT_TARGET=12.0

# Set the target architectures and platforms
# Format: "platform:architecture:configure_target"
targets=(
    "iPhoneOS:arm64:ios64-xcrun"
    "iPhoneSimulator:arm64:iossimulator-xcrun"
    "iPhoneSimulator:x86_64:iossimulator-xcrun"
)

for target in "${targets[@]}"
do
    IFS=':' read -r platform arch configure_target <<< "$target"

    echo "Building OpenSSL for ${platform} ${arch}..."

    cd ${OPENSSL_DIR}

    # Set SDK path
    SDK_PATH=$(xcrun --sdk $(echo $platform | tr '[:upper:]' '[:lower:]') --show-sdk-path)

    # Configure OpenSSL
    export CROSS_TOP="${SDK_PATH%/SDKs/*}"
    export CROSS_SDK="${SDK_PATH##*/SDKs/}"

    # Set CC with explicit architecture flag
    if [ "$platform" = "iPhoneOS" ]; then
        export CC="xcrun -sdk iphoneos clang -arch ${arch}"
        ./Configure ${configure_target} no-shared no-async -mios-version-min=${IOS_DEPLOYMENT_TARGET} --prefix=${SCRIPTPATH}/build/${platform}/${arch}
    else
        # Simulator builds need explicit architecture
        export CC="xcrun -sdk iphonesimulator clang -arch ${arch}"
        ./Configure iossimulator-xcrun no-shared no-async -mios-simulator-version-min=${IOS_DEPLOYMENT_TARGET} --prefix=${SCRIPTPATH}/build/${platform}/${arch}
    fi

    make clean || true
    make -j$(sysctl -n hw.ncpu)
    make install_sw

    # Copy the outputs
    if [ ! -d "${SCRIPTPATH}/include/openssl" ]; then
        OUTPUT_INCLUDE=$SCRIPTPATH/include
        mkdir -p $OUTPUT_INCLUDE
        cp -R ${SCRIPTPATH}/build/${platform}/${arch}/include/openssl $OUTPUT_INCLUDE/
    fi

    # Determine output directory based on platform
    if [ "$platform" = "iPhoneOS" ]; then
        OUTPUT_LIB=$SCRIPTPATH/lib/iphoneos/${arch}
    else
        OUTPUT_LIB=$SCRIPTPATH/lib/iphonesimulator/${arch}
    fi

    mkdir -p $OUTPUT_LIB
    cp ${SCRIPTPATH}/build/${platform}/${arch}/lib/libcrypto.a $OUTPUT_LIB/
    cp ${SCRIPTPATH}/build/${platform}/${arch}/lib/libssl.a $OUTPUT_LIB/

    make clean
done

echo "OpenSSL build complete!"
echo "Headers: ${SCRIPTPATH}/include/openssl"
echo "Libraries: ${SCRIPTPATH}/lib/"
