import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Features

// MARK: - Transfer List

let transferList = Feature(name: "TransferList")

// MARK: New Transfer & Upload

let newTransferView = Feature(name: "NewTransferView", additionalDependencies: [
    TargetDependency.external(name: "InfomaniakConcurrency")
])
let uploadProgressView = Feature(name: "UploadProgressView", additionalDependencies: [
    TargetDependency.external(name: "InfomaniakCore"),
    TargetDependency.external(name: "InfomaniakConcurrency")
])

let rootTransferView = Feature(name: "RootTransferView", dependencies: [newTransferView, uploadProgressView])

// MARK: Root

let transferDetailsView = Feature(name: "TransferDetailsView")
let receivedView = Feature(name: "ReceivedView", additionalDependencies: [transferDetailsView, transferList])
let sentView = Feature(name: "SentView", additionalDependencies: [transferDetailsView, transferList])

let settingsView = Feature(name: "SettingsView")

let mainView = Feature(name: "MainView", additionalDependencies: [settingsView, receivedView, sentView, rootTransferView])

let onboardingView = Feature(name: "OnboardingView", additionalDependencies: [
    TargetDependency.external(name: "InfomaniakOnboarding")
])

let rootView = Feature(
    name: "RootView",
    dependencies: [mainView, onboardingView],
    resources: ["SwissTransfer/Resources/Assets.xcassets"]
)

let mainiOSAppFeatures = [
    rootView,
    mainView,
    onboardingView,
    sentView,
    receivedView,
    settingsView,
    transferDetailsView,
    uploadProgressView,
    newTransferView,
    rootTransferView,
    transferList
]

// MARK: - Project

let project = Project(
    name: "SwissTransfer",
    targets: mainiOSAppFeatures.asTargets + [
        .target(
            name: "SwissTransfer",
            destinations: Set<Destination>([.iPhone, .iPad]),
            product: .app,
            bundleId: Constants.baseIdentifier,
            deploymentTargets: Constants.deploymentTarget,
            infoPlist: "SwissTransfer/Resources/Info.plist",
            sources: "SwissTransfer/Sources/**",
            resources: [
                "SwissTransfer/Resources/LaunchScreen.storyboard",
                "SwissTransfer/Resources/Assets.xcassets", // Needed for AppIcon and LaunchScreen
                "SwissTransfer/Resources/PrivacyInfo.xcprivacy",
                "SwissTransfer/Resources/Localizable/**/InfoPlist.strings"
            ],
            entitlements: "SwissTransfer/Resources/SwissTransfer.entitlements",
            scripts: [
                Constants.swiftlintScript,
                Constants.stripSymbolsScript
            ],
            dependencies: [
                .target(name: "SwissTransferCore"),
                .target(name: "SwissTransferCoreUI"),
                rootView.asDependency
            ],
            settings: .settings(base: Constants.baseSettings),
            environmentVariables: [
                "hostname": .environmentVariable(value: "\(ProcessInfo.processInfo.hostName).", isEnabled: true)
            ]
        ),
        .target(
            name: "SwissTransferTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(Constants.baseIdentifier).SwissTransferTests",
            deploymentTargets: Constants.deploymentTarget,
            infoPlist: .default,
            sources: "SwissTransferTests/**",
            resources: [],
            dependencies: [.target(name: "SwissTransfer")],
            settings: .settings(base: Constants.baseSettings),
            environmentVariables: [
                "hostname": .environmentVariable(value: "\(ProcessInfo.processInfo.hostName).", isEnabled: true)
            ]
        ),
        .target(name: "SwissTransferCore",
                destinations: Constants.destinations,
                product: Constants.productTypeBasedOnEnv,
                bundleId: "\(Constants.baseIdentifier).core",
                deploymentTargets: Constants.deploymentTarget,
                infoPlist: .default,
                sources: "SwissTransferCore/**",
                dependencies: [
                    .target(name: "STResources"),
                    .external(name: "InfomaniakCoreCommonUI"),
                    .external(name: "InfomaniakCoreSwiftUI"),
                    .external(name: "InfomaniakCoreUIKit"),
                    .external(name: "InfomaniakDeviceCheck"),
                    .external(name: "STCore"),
                    .external(name: "STNetwork"),
                    .external(name: "STDatabase"),
                    .external(name: "Sentry")
                ],
                settings: .settings(base: Constants.baseSettings)),
        .target(name: "SwissTransferCoreUI",
                destinations: Constants.destinations,
                product: Constants.productTypeBasedOnEnv,
                bundleId: "\(Constants.baseIdentifier).coreui",
                deploymentTargets: Constants.deploymentTarget,
                infoPlist: .default,
                sources: "SwissTransferCoreUI/**",
                dependencies: [
                    .target(name: "SwissTransferCore"),
                    .external(name: "QRCode"),
                    .external(name: "SwiftUIIntrospect-Static")
                ],
                settings: .settings(base: Constants.baseSettings)),
        .target(name: "STResources",
                destinations: Constants.destinations,
                product: Constants.productTypeBasedOnEnv,
                bundleId: "\(Constants.baseIdentifier).resources",
                deploymentTargets: Constants.deploymentTarget,
                infoPlist: .default,
                resources: [
                    "SwissTransferResources/**/*.xcassets",
                    "SwissTransferResources/**/*.strings",
                    "SwissTransferResources/**/*.stringsdict",
                    "SwissTransferResources/**/*.json"
                ],
                settings: .settings(base: Constants.baseSettings))
    ],
    fileHeaderTemplate: .file("file-header-template.txt")
)
