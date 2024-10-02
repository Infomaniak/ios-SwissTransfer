import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Features

// MARK: - Transfer List

let transferList = Feature(name: "TransferList")

// MARK: New Transfer

let newTransferView = Feature(name: "NewTransferView")

// MARK: New Upload

let uploadProgressView = Feature(name: "UploadProgressView")

// MARK: Root

let transferDetailsView = Feature(name: "TransferDetailsView")
let receivedView = Feature(name: "ReceivedView", additionalDependencies: [transferDetailsView, transferList])
let sentView = Feature(name: "SentView", additionalDependencies: [transferDetailsView, transferList])

let settingsView = Feature(name: "SettingsView")

let mainView = Feature(name: "MainView", additionalDependencies: [settingsView, receivedView, sentView])

let onboardingView = Feature(name: "OnboardingView")

let rootView = Feature(name: "RootView", dependencies: [mainView, onboardingView])

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
            infoPlist: .extendingDefault(
                with: [
                    "AppIdentifierPrefix": "$(AppIdentifierPrefix)",
                    "CFBundleDisplayName": "$(PRODUCT_NAME)",
                    "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                    "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                    "UILaunchStoryboardName": "LaunchScreen.storyboard"
                ]
            ),
            sources: "SwissTransfer/Sources/**",
            resources: [
                "SwissTransfer/Resources/LaunchScreen.storyboard",
                "SwissTransfer/Resources/Assets.xcassets", // Needed for AppIcon
                "SwissTransfer/Resources/PrivacyInfo.xcprivacy"
            ],
            scripts: [Constants.swiftlintScript],
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
                    .external(name: "STCore"),
                    .external(name: "STNetwork"),
                    .external(name: "STDatabase")
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
                    .target(name: "SwissTransferCore")
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
