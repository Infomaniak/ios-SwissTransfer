// swift-tools-version: 5.9
@preconcurrency import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "InfomaniakDI": .framework,
        "InfomaniakCore": .framework,
        "InfomaniakCoreSwiftUI": .framework
    ]
)
#endif

let package = Package(
    name: "SwissTransfer",
    dependencies: [
        .package(url: "https://github.com/Infomaniak/ios-core", .upToNextMajor(from: "12.7.0")),
        .package(url: "https://github.com/Infomaniak/ios-core-ui", .upToNextMajor(from: "14.0.0")),
        .package(url: "https://github.com/Infomaniak/ios-onboarding", .upToNextMajor(from: "1.1.1")),
        .package(url: "https://github.com/Infomaniak/multiplatform-SwissTransfer", .upToNextMajor(from: "0.1.0")),
        .package(url: "https://github.com/Infomaniak/swift-concurrency", .upToNextMajor(from: "0.0.6")),
        .package(url: "https://github.com/getsentry/sentry-cocoa", .upToNextMajor(from: "8.0.0")),
        .package(url: "https://github.com/dagronf/QRCode", .upToNextMajor(from: "22.0.0"))
    ]
)
