// swift-tools-version: 5.9
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "InfomaniakDI": .framework,
        "InfomaniakCoreSwiftUI": .framework
    ]
)
#endif

let package = Package(
    name: "SwissTransfer",
    dependencies: [
        .package(url: "https://github.com/Infomaniak/ios-core-ui", .upToNextMajor(from: "13.0.0")),
        .package(url: "https://github.com/Infomaniak/multiplatform-SwissTransfer", .upToNextMajor(from: "0.1.0"))
    ]
)
