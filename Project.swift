import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Features

// MARK: - Transfer List

let transferList = Feature(name: "TransferList")

// MARK: New Transfer & Upload

let newTransferView = Feature(name: "NewTransferView", additionalDependencies: [
    TargetDependency.external(name: "InfomaniakCoreUIResources"),
    TargetDependency.external(name: "InfomaniakConcurrency"),
    TargetDependency.external(name: "OrderedCollections")
])
let uploadProgressView = Feature(name: "UploadProgressView", additionalDependencies: [
    TargetDependency.external(name: "InfomaniakCore"),
    TargetDependency.external(name: "InfomaniakCoreUIResources"),
    TargetDependency.external(name: "InfomaniakConcurrency")
])

let rootTransferView = Feature(name: "RootTransferView", dependencies: [newTransferView, uploadProgressView])

// MARK: Root

let preloadingView = Feature(name: "PreloadingView")
let transferDetailsView = Feature(name: "TransferDetailsView")
let deepLinkPasswordView = Feature(name: "DeepLinkPasswordView")
let receivedView = Feature(name: "ReceivedView", additionalDependencies: [transferList])
let sentView = Feature(name: "SentView", additionalDependencies: [transferList])

let settingsView = Feature(
    name: "SettingsView",
    additionalDependencies: [
        TargetDependency.external(name: "InfomaniakPrivacyManagement"),
        TargetDependency.external(name: "InfomaniakCoreUIResources")
    ]
)

let mainView = Feature(
    name: "MainView",
    additionalDependencies: [
        settingsView,
        receivedView,
        sentView,
        transferDetailsView,
        rootTransferView,
        deepLinkPasswordView,
        TargetDependency.external(name: "InfomaniakCoreUIResources"),
        TargetDependency.external(name: "VersionChecker")
    ]
)

let onboardingView = Feature(name: "OnboardingView", additionalDependencies: [
    TargetDependency.external(name: "InfomaniakCoreUIResources"),
    TargetDependency.external(name: "InfomaniakOnboarding"),
    TargetDependency.external(name: "Lottie")
])

let rootView = Feature(
    name: "RootView",
    dependencies: [mainView, preloadingView, onboardingView, TargetDependency.external(name: "VersionChecker")]
)

let mainiOSAppFeatures = [
    rootView,
    mainView,
    preloadingView,
    onboardingView,
    sentView,
    receivedView,
    settingsView,
    transferDetailsView,
    uploadProgressView,
    newTransferView,
    rootTransferView,
    transferList,
    deepLinkPasswordView
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
                "SwissTransfer/Resources/Assets.xcassets", // Needed for LaunchScreen
                "SwissTransfer/Resources/PrivacyInfo.xcprivacy",
                "SwissTransfer/Resources/Localizable/**/InfoPlist.strings",
                "SwissTransfer/Resources/AppIcon.icon"
            ],
            entitlements: "SwissTransfer/Resources/SwissTransfer.entitlements",
            scripts: [
                Constants.swiftlintScript,
                Constants.stripSymbolsScript
            ],
            dependencies: [
                .target(name: "SwissTransferCore"),
                .target(name: "SwissTransferCoreUI"),
                .target(name: "SwissTransferShareExtension"),
                .target(name: "SwissTransfer - App Clip"),
                rootView.asDependency
            ],
            settings: .settings(base: Constants.baseSettings),
            environmentVariables: [
                "hostname": .environmentVariable(value: "\(ProcessInfo.processInfo.hostName).", isEnabled: true)
            ]
        ),
        .target(
            name: "SwissTransfer - App Clip",
            destinations: Set<Destination>([.iPhone, .iPad]),
            product: .appClip,
            bundleId: "\(Constants.baseIdentifier).Clip",
            deploymentTargets: DeploymentTargets.iOS("17.0"),
            infoPlist: "SwissTransfer - App Clip/Resources/Info.plist",
            sources: "SwissTransfer - App Clip/Sources/**",
            resources: [
                "SwissTransfer/Resources/LaunchScreen.storyboard",
                "SwissTransfer/Resources/Assets.xcassets", // Needed for AppIcon and LaunchScreen
                "SwissTransfer/Resources/Localizable/**/InfoPlist.strings",
                "SwissTransfer/Resources/AppIcon.icon"
            ],
            entitlements: "SwissTransfer - App Clip/Resources/SwissTransfer.entitlements",
            dependencies: [
                .target(name: "SwissTransferCore"),
                .target(name: "SwissTransferCoreUI"),
                .external(name: "InfomaniakCoreUIResources"),
                preloadingView.asDependency,
                receivedView.asDependency,
                transferDetailsView.asDependency,
                deepLinkPasswordView.asDependency
            ],
            settings: .settings(base: Constants.baseSettings)
        ),
        .target(
            name: "SwissTransferShareExtension",
            destinations: Set<Destination>([.iPhone, .iPad]),
            product: .appExtension,
            bundleId: "\(Constants.baseIdentifier).ShareExtension",
            deploymentTargets: Constants.deploymentTarget,
            infoPlist: .extendingDefault(with: [
                "CFBundleName": "$(PRODUCT_NAME)",
                "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                "AppIdentifierPrefix": "$(AppIdentifierPrefix)",
                "CFBundleDisplayName": "$(PRODUCT_NAME)",
                "NSExtension": [
                    "NSExtensionPointIdentifier": "com.apple.share-services",
                    "NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).ShareViewController",
                    "NSExtensionAttributes": ["NSExtensionActivationRule": "SUBQUERY (extensionItems, $extensionItem, SUBQUERY ($extensionItem.attachments, $attachment, (ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO \"public.data\")).@count == $extensionItem.attachments.@count ).@count > 0"]
                ]
            ]),
            sources: "SwissTransferShareExtension/Sources/**",
            resources: [],
            entitlements: "SwissTransferShareExtension/Resources/SwissTransfer.entitlements",
            dependencies: [
                .target(name: "SwissTransferCore"),
                .target(name: "SwissTransferCoreUI"),
                rootTransferView.asDependency
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
                    .external(name: "InfomaniakConcurrency"),
                    .external(name: "DesignSystem"),
                    .external(name: "InfomaniakDeviceCheck"),
                    .external(name: "STCore"),
                    .external(name: "STNetwork"),
                    .external(name: "STDatabase"),
                    .external(name: "Sentry-Dynamic")
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
                    .external(name: "InfomaniakCoreUIResources"),
                    .external(name: "SwiftModalPresentation"),
                    .external(name: "QRCode"),
                    .external(name: "SwiftUIIntrospect-Static"),
                    .external(name: "OrderedCollections")
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
                    "SwissTransferResources/**/*.json",
                    "SwissTransferResources/**/*.lottie"
                ],
                settings: .settings(base: Constants.baseSettings))
    ],
    fileHeaderTemplate: .file("file-header-template.txt")
)
