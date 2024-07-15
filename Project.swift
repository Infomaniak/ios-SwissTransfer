import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Transfer

let newTransferView = Feature(name: "NewTransferView")

// MARK: - Upload

let uploadProgressView = Feature(name: "UploadProgressView")

// MARK: - Root

let transferDetailsView = Feature(name: "TransferDetailsView")

let settingsView = Feature(name: "SettingsView")
let receivedView = Feature(name: "ReceivedView", dependencies: [transferDetailsView])
let sentView = Feature(name: "SentView", dependencies: [transferDetailsView])

let onboardingView = Feature(name: "OnboardingView")
let mainView = Feature(name: "MainView", dependencies: [settingsView, receivedView])

let rootView = Feature(name: "RootView", dependencies: [mainView, onboardingView])

let mainiOSAppFeatures = [rootView, mainView, onboardingView, sentView, receivedView, settingsView, transferDetailsView, uploadProgressView, newTransferView]

let project = Project(
    name: "SwissTransfer",
    targets: mainiOSAppFeatures.asTargets + [
        .target(
            name: "SwissTransfer",
            destinations: Set<Destination>([.iPhone, .iPad]),
            product: .app,
            bundleId: Constants.baseIdentifier,
            infoPlist: .extendingDefault(
                with: [
                    "AppIdentifierPrefix": "$(AppIdentifierPrefix)",
                    "CFBundleDisplayName": "$(PRODUCT_NAME)",
                    "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                    "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                    "UILaunchStoryboardName": "LaunchScreen.storyboard"
                ]
            ),
            sources: ["SwissTransfer/Sources/**"],
            resources: [
                "SwissTransfer/Resources/LaunchScreen.storyboard",
                "SwissTransfer/Resources/Assets.xcassets", // Needed for AppIcon
                "SwissTransfer/Resources/PrivacyInfo.xcprivacy"
            ],
            scripts: [Constants.swiftlintScript],
            dependencies: mainiOSAppFeatures.asDependencies + [],
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
            bundleId: "\(Constants.baseIdentifier).SwissTransferTests",
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
                bundleId: "\(Constants.baseIdentifier).core",
                deploymentTargets: Constants.deploymentTarget,
                infoPlist: .default,
                sources: "SwissTransferCore/**",
                dependencies: [
                ],
                settings: .settings(base: Constants.baseSettings)),
        .target(name: "SwissTransferCoreUI",
                destinations: Constants.destinations,
                product: .framework,
                bundleId: "\(Constants.baseIdentifier).coreui",
                deploymentTargets: Constants.deploymentTarget,
                infoPlist: .default,
                sources: "SwissTransferCoreUI/**",
                dependencies: [
                ],
                settings: .settings(base: Constants.baseSettings)),
        .target(name: "SwissTransferResources",
                destinations: Constants.destinations,
                product: .staticLibrary,
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
