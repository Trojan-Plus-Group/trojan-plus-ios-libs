# Trojan Plus iOS Libraries

Pre-built OpenSSL and Boost libraries for iOS, used by the [trojan-plus](https://github.com/Trojan-Plus-Group/trojan-plus) project.

## Directory Structure

```
trojan-plus-ios-libs/
├── include/
│   ├── boost/          # Boost headers
│   └── openssl/        # OpenSSL headers
├── lib/
│   ├── iphoneos/
│   │   └── arm64/
│   │       ├── libssl.a
│   │       ├── libcrypto.a
│   │       ├── libboost_system.a
│   │       └── libboost_program_options.a
│   └── iphonesimulator/
│       ├── arm64/      # Apple Silicon simulators
│       │   ├── libssl.a
│       │   ├── libcrypto.a
│       │   ├── libboost_system.a
│       │   └── libboost_program_options.a
│       └── x86_64/     # Intel simulators
│           ├── libssl.a
│           ├── libcrypto.a
│           ├── libboost_system.a
│           └── libboost_program_options.a
├── make_openssl.sh
├── make_boost.sh
└── README.md
```

## Building Dependencies

### Prerequisites

- macOS with Xcode installed
- Xcode Command Line Tools
- Git

### Build OpenSSL 3.0.15

```bash
./make_openssl.sh
```

This script will:
1. Download OpenSSL 3.0.15 source code
2. Build for iOS device (arm64)
3. Build for iOS simulator (arm64, x86_64)
4. Copy headers to `include/openssl/`
5. Copy libraries to `lib/iphoneos/` and `lib/iphonesimulator/`

### Build Boost 1.85.0

```bash
./make_boost.sh
```

This script will:
1. Clone [boost-iosx](https://github.com/apotocki/boost-iosx) build system
2. Download and build Boost 1.85.0
3. Build system and program_options components
4. Build for iOS device (arm64)
5. Build for iOS simulator (arm64, x86_64)
6. Copy headers to `include/boost/`
7. Copy libraries to `lib/iphoneos/` and `lib/iphonesimulator/`

### Build All

```bash
./make_openssl.sh && ./make_boost.sh
```

## Library Versions

- **OpenSSL**: 3.0.15
- **Boost**: 1.85.0
- **iOS Deployment Target**: 12.0+

## Architectures

- **Device**: arm64 (iPhone 5s and later, all iPads with A7 chip or later)
- **Simulator**:
  - arm64 (Apple Silicon Macs)
  - x86_64 (Intel Macs)

## Build Configuration

### OpenSSL

- Static libraries (`.a`)
- No shared libraries
- No async support (for compatibility)
- Minimum iOS version: 12.0

### Boost

- Static libraries (`.a`)
- Components: system, program_options
- Minimum iOS version: 12.0
- C++17 standard

## Usage

This repository is used as a git submodule in the trojan-plus project:

```bash
cd trojan-plus
git submodule update --init --recursive
cd trojan-plus-ios-libs
./make_openssl.sh
./make_boost.sh
cd ..
./make_ios.sh /Applications/Xcode.app -r
```

## Notes

- Build time: ~30-60 minutes depending on your machine
- Disk space required: ~2-3 GB during build, ~100 MB final output
- The build scripts are idempotent - you can run them multiple times
- Intermediate build files are kept in `build/` and `boost-iosx/` directories

## Troubleshooting

### OpenSSL build fails

Make sure you have Xcode Command Line Tools installed:
```bash
xcode-select --install
```

### Boost build fails

The boost-iosx script requires:
- Git
- Xcode with iOS SDK
- Command Line Tools

Check that you can run:
```bash
xcrun --sdk iphoneos --show-sdk-path
xcrun --sdk iphonesimulator --show-sdk-path
```

### Architecture not found

Make sure you're building on macOS with Xcode installed. The scripts use `xcrun` to locate the iOS SDK.

## License

- OpenSSL: Apache License 2.0
- Boost: Boost Software License 1.0

## References

- [OpenSSL](https://www.openssl.org/)
- [Boost](https://www.boost.org/)
- [boost-iosx](https://github.com/apotocki/boost-iosx) - iOS Boost build system
- [trojan-plus](https://github.com/Trojan-Plus-Group/trojan-plus) - Main project
