// swift-tools-version: 5.9
@preconcurrency import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "Alamofire": .framework,
        "InfomaniakDI": .framework,
        "InfomaniakCore": .framework,
        "InfomaniakCoreSwiftUI": .framework,
        "InfomaniakCoreUIResources": .framework,
        "InfomaniakConcurrency": .framework,
        "SwiftUIIntrospect": .framework,
        "OrderedCollections": .framework,
        "Lottie": .framework,
        "SwissTransferCore": .framework,
        "STSettingsView": .framework,
        "DesignSystem": .framework,
        "VersionChecker": .framework
    ]
)
#endif

let package = Package(
    name: "SwissTransfer",
    dependencies: [
        .package(url: "https://github.com/Infomaniak/ios-core", .upToNextMajor(from: "15.0.1")),
        .package(url: "https://github.com/Infomaniak/ios-core-ui", .upToNextMajor(from: "18.6.0")),
        .package(url: "https://github.com/Infomaniak/ios-onboarding", .upToNextMajor(from: "1.1.2")),
        .package(url: "https://github.com/Infomaniak/ios-device-check", .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/Infomaniak/multiplatform-SwissTransfer", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/Infomaniak/swift-concurrency", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/Infomaniak/swift-modal-presentation", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/getsentry/sentry-cocoa", .upToNextMajor(from: "8.0.0")),
        .package(url: "https://github.com/dagronf/QRCode", .upToNextMajor(from: "22.0.0")),
        .package(url: "https://github.com/siteline/SwiftUI-Introspect", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-collections", .upToNextMajor(from: "1.1.4")),
        .package(url: "https://github.com/matomo-org/matomo-sdk-ios", .upToNextMajor(from: "7.7.0")),
        .package(url: "https://github.com/airbnb/lottie-spm.git", .upToNextMajor(from: "4.5.1")),
        .package(url: "https://github.com/Infomaniak/ios-version-checker", .upToNextMajor(from: "10.1.1"))
    ]
)
