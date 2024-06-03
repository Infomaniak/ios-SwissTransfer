import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let baseIdentifier = "com.infomaniak.swisstransfer"

func featureTarget(name: String,
                   destinations: Set<Destination> = Set<Destination>([.iPhone, .iPad]),
                   dependencies: [TargetDependency] = [.target(name: "SwissTransferCore"),
                                                       .target(name: "SwissTransferCoreUI")]) -> Target {
    .target(name: "ST\(name)",
            destinations: destinations,
            product: .framework,
            bundleId: "\(baseIdentifier).features.\(name)",
            deploymentTargets: Constants.deploymentTarget,
            infoPlist: .default,
            sources: "SwissTransferFeatures/\(name)/",
            dependencies: dependencies,
            settings: .settings(base: Constants.baseSettings))
}

let project = Project(
    name: "SwissTransfer",
    targets: [
        .target(
            name: "SwissTransfer",
            destinations: Set<Destination>([.iPhone, .iPad]),
            product: .app,
            bundleId: baseIdentifier,
            infoPlist: .extendingDefault(
                with: [
                    "AppIdentifierPrefix": "$(AppIdentifierPrefix)",
                    "CFBundleDisplayName": "$(PRODUCT_NAME)",
                    "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                    "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                ]
            ),
            sources: ["SwissTransfer/Sources/**"],
            resources: [
                "SwissTransfer/Resources/LaunchScreen.storyboard",
                "SwissTransfer/Resources/Assets.xcassets", // Needed for AppIcon
                "SwissTransfer/Resources/PrivacyInfo.xcprivacy",
            ],
            dependencies: [],
            settings: .settings(base: Constants.baseSettings),
            environmentVariables: [
                "hostname": .environmentVariable(value: "\(ProcessInfo.processInfo.hostName).",
                                                 isEnabled: true)
            ]
        ),
        .target(
            name: "SwissTransferTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.infomaniak.swisstransfer.SwissTransferTests",
            infoPlist: .default,
            sources: ["SwissTransferTests/**"],
            resources: [],
            dependencies: [.target(name: "SwissTransfer")],
            settings: .settings(base: Constants.baseSettings),
            environmentVariables: [
                "hostname": .environmentVariable(value: "\(ProcessInfo.processInfo.hostName).",
                                                 isEnabled: true)
            ]
        ),
        .target(name: "SwissTransferCore",
                destinations: Constants.destinations,
                product: .framework,
                bundleId: "\(baseIdentifier).core",
                deploymentTargets: Constants.deploymentTarget,
                infoPlist: .default,
                sources: "SwissTransferCore/**",
                dependencies: [
                ],
                settings: .settings(base: Constants.baseSettings)),
        .target(name: "SwissTransferCoreUI",
                destinations: Constants.destinations,
                product: .framework,
                bundleId: "\(baseIdentifier).coreui",
                deploymentTargets: Constants.deploymentTarget,
                infoPlist: .default,
                sources: "SwissTransferCoreUI/**",
                dependencies: [
                ],
                settings: .settings(base: Constants.baseSettings)),
        .target(name: "SwissTransferResources",
                destinations: Constants.destinations,
                product: .staticLibrary,
                bundleId: "\(baseIdentifier).resources",
                deploymentTargets: Constants.deploymentTarget,
                infoPlist: .default,
                resources: [
                    "SwissTransferResources/**/*.xcassets",
                    "SwissTransferResources/**/*.strings",
                    "SwissTransferResources/**/*.stringsdict",
                    "SwissTransferResources/**/*.json",
                ],
                settings: .settings(base: Constants.baseSettings)),
    ],
    fileHeaderTemplate: .file("file-header-template.txt")
)
