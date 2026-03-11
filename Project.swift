import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Features

// MARK: - Transfer List

let transferList = Feature(name: "TransferList", additionalDependencies: [
    TargetDependency.target(name: "STResources"),
    TargetDependency.external(name: "DesignSystem"),
    TargetDependency.external(name: "InfomaniakCoreCommonUI"),
    TargetDependency.external(name: "InfomaniakCoreSwiftUI"),
    TargetDependency.external(name: "InfomaniakDI")
])

// MARK: New Transfer & Upload

let newTransferView = Feature(name: "NewTransferView", additionalDependencies: [
    TargetDependency.target(name: "STResources"),
    TargetDependency.external(name: "DesignSystem"),
    TargetDependency.external(name: "InfomaniakConcurrency"),
    TargetDependency.external(name: "InfomaniakCoreCommonUI"),
    TargetDependency.external(name: "InfomaniakCoreSwiftUI"),
    TargetDependency.external(name: "InfomaniakCoreUIResources"),
    TargetDependency.external(name: "InfomaniakCore"),
    TargetDependency.external(name: "InfomaniakDI"),
    TargetDependency.external(name: "OrderedCollections")
])
let uploadProgressView = Feature(name: "UploadProgressView", additionalDependencies: [
    TargetDependency.target(name: "STResources"),
    TargetDependency.external(name: "DesignSystem"),
    TargetDependency.external(name: "InfomaniakConcurrency"),
    TargetDependency.external(name: "InfomaniakCoreCommonUI"),
    TargetDependency.external(name: "InfomaniakCoreSwiftUI"),
    TargetDependency.external(name: "InfomaniakCoreUIResources"),
    TargetDependency.external(name: "InfomaniakCore"),
    TargetDependency.external(name: "OrderedCollections")
])

let rootTransferView = Feature(name: "RootTransferView", additionalDependencies: [
    newTransferView,
    uploadProgressView,
    TargetDependency.external(name: "InfomaniakCore")
])

// MARK: Root

let preloadingView = Feature(name: "PreloadingView", additionalDependencies: [
    TargetDependency.target(name: "STResources"),
    TargetDependency.external(name: "DesignSystem"),
    TargetDependency.external(name: "InfomaniakCore"),
    TargetDependency.external(name: "InfomaniakCoreSwiftUI"),
    TargetDependency.external(name: "InfomaniakCoreUIResources"),
    TargetDependency.external(name: "InfomaniakDI")
])
let transferDetailsView = Feature(name: "TransferDetailsView", additionalDependencies: [
    TargetDependency.target(name: "STResources"),
    TargetDependency.external(name: "DesignSystem"),
    TargetDependency.external(name: "InfomaniakCoreCommonUI"),
    TargetDependency.external(name: "InfomaniakCoreSwiftUI"),
    TargetDependency.external(name: "InfomaniakDI")
])
let deepLinkPasswordView = Feature(name: "DeepLinkPasswordView", additionalDependencies: [
    TargetDependency.target(name: "STResources"),
    TargetDependency.external(name: "DesignSystem"),
    TargetDependency.external(name: "InfomaniakCoreSwiftUI"),
    TargetDependency.external(name: "InfomaniakCoreUIResources"),
    TargetDependency.external(name: "InfomaniakDI")
])
let receivedView = Feature(name: "ReceivedView", additionalDependencies: [
    transferList,
    TargetDependency.target(name: "STResources")
])
let sentView = Feature(name: "SentView", additionalDependencies: [
    transferList,
    TargetDependency.target(name: "STResources"),
    TargetDependency.external(name: "DesignSystem"),
    TargetDependency.external(name: "InfomaniakCoreCommonUI"),
    TargetDependency.external(name: "InfomaniakCoreSwiftUI")
])

let settingsView = Feature(
    name: "SettingsView",
    additionalDependencies: [
        TargetDependency.target(name: "STResources"),
        TargetDependency.external(name: "InfomaniakPrivacyManagement"),
        TargetDependency.external(name: "InfomaniakCoreUIResources"),
        TargetDependency.external(name: "SwiftModalPresentation")
    ]
)

let onboardingView = Feature(name: "OnboardingView", additionalDependencies: [
    TargetDependency.target(name: "STResources"),
    TargetDependency.external(name: "InfomaniakCoreUIResources"),
    TargetDependency.external(name: "InfomaniakCreateAccount"),
    TargetDependency.external(name: "InfomaniakDeviceCheck"),
    TargetDependency.external(name: "InfomaniakOnboarding"),
    TargetDependency.external(name: "InterAppLogin"),
    TargetDependency.external(name: "Lottie")
])

let accountView = Feature(
    name: "AccountView",
    additionalDependencies: [
        settingsView,
        onboardingView,
        TargetDependency.target(name: "STResources"),
        TargetDependency.external(name: "DesignSystem"),
        TargetDependency.external(name: "InfomaniakCoreCommonUI"),
        TargetDependency.external(name: "InfomaniakCoreSwiftUI"),
        TargetDependency.external(name: "InfomaniakCoreUIResources"),
        TargetDependency.external(name: "InfomaniakCore"),
        TargetDependency.external(name: "InfomaniakDI"),
        TargetDependency.external(name: "InfomaniakLogin")
    ]
)

let mainView = Feature(
    name: "MainView",
    additionalDependencies: [
        accountView,
        receivedView,
        sentView,
        transferDetailsView,
        rootTransferView,
        deepLinkPasswordView,
        TargetDependency.target(name: "STResources"),
        TargetDependency.external(name: "InAppTwoFactorAuthentication"),
        TargetDependency.external(name: "InfomaniakCoreUIResources"),
        TargetDependency.external(name: "VersionChecker")
    ]
)

let rootView = Feature(
    name: "RootView",
    additionalDependencies: [
        mainView,
        preloadingView, onboardingView,
        TargetDependency.target(name: "STResources"),
        TargetDependency.external(name: "VersionChecker")
    ]
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
    deepLinkPasswordView,
    accountView
]

// MARK: - Project

let project = Project(
    name: "SwissTransfer",
    options: .options(developmentRegion: "en"),
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
                "SwissTransfer/Resources/AppIcon.icon/**"
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
                .external(name: "InfomaniakCoreSwiftUI"),
                .external(name: "InfomaniakCore"),
                .external(name: "InfomaniakDI"),
                .external(name: "InfomaniakNotifications"),
                .external(name: "VersionChecker"),
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
                "SwissTransfer/Resources/AppIcon.icon/**"
            ],
            entitlements: "SwissTransfer - App Clip/Resources/SwissTransfer.entitlements",
            dependencies: [
                .target(name: "SwissTransferCore"),
                .target(name: "SwissTransferCoreUI"),
                .external(name: "InfomaniakCoreCommonUI"),
                .external(name: "InfomaniakCoreSwiftUI"),
                .external(name: "InfomaniakCoreUIResources"),
                .external(name: "InfomaniakCore"),
                .external(name: "InfomaniakDI"),
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
                    "NSExtensionAttributes": [
                        "NSExtensionActivationRule": "SUBQUERY (extensionItems, $extensionItem, SUBQUERY ($extensionItem.attachments, $attachment, (ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO \"public.data\")).@count == $extensionItem.attachments.@count ).@count > 0"
                    ]
                ]
            ]),
            sources: "SwissTransferShareExtension/Sources/**",
            resources: [],
            entitlements: "SwissTransferShareExtension/Resources/SwissTransfer.entitlements",
            dependencies: [
                .target(name: "SwissTransferCore"),
                .target(name: "SwissTransferCoreUI"),
                .external(name: "InfomaniakDI"),
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
            dependencies: [
                .target(name: "SwissTransfer"),
                .target(name: "SwissTransferCoreUI")
            ],
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
                    .external(name: "DesignSystem"),
                    .external(name: "DeviceAssociation"),
                    .external(name: "InAppTwoFactorAuthentication"),
                    .external(name: "InfomaniakConcurrency"),
                    .external(name: "InfomaniakCoreCommonUI"),
                    .external(name: "InfomaniakCoreSwiftUI"),
                    .external(name: "InfomaniakCoreUIKit"),
                    .external(name: "InfomaniakDeviceCheck"),
                    .external(name: "InfomaniakNotifications"),
                    .external(name: "InterAppLogin"),
                    .external(name: "OrderedCollections"),
                    .external(name: "Sentry-Dynamic"),
                    .external(name: "STCore"),
                    .external(name: "STDatabase"),
                    .external(name: "STNetwork")
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
                    .target(name: "STResources"),
                    .external(name: "DesignSystem"),
                    .external(name: "InfomaniakConcurrency"),
                    .external(name: "InfomaniakCoreCommonUI"),
                    .external(name: "InfomaniakCoreSwiftUI"),
                    .external(name: "InfomaniakCoreUIResources"),
                    .external(name: "InfomaniakCore"),
                    .external(name: "InfomaniakDI"),
                    .external(name: "NukeUI"),
                    .external(name: "OrderedCollections"),
                    .external(name: "QRCode"),
                    .external(name: "SwiftModalPresentation"),
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
                    "SwissTransferResources/**/*.json",
                    "SwissTransferResources/**/*.lottie"
                ],
                settings: .settings(base: Constants.baseSettings))
    ],
    fileHeaderTemplate: .file("file-header-template.txt")
)
