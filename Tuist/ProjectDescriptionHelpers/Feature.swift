import Foundation
import ProjectDescription

public extension [Feature] {
    var asTargets: [Target] {
        return map { $0.asTarget }
    }

    var asDependencies: [TargetDependency] {
        return map { $0.asDependency }
    }
}

public struct Feature {
    let name: String
    var targetName: String {
        "ST\(name)"
    }

    let destinations: Set<Destination>
    let dependencies: [TargetDependency]

    public init(name: String,
                destinations: Set<Destination> = Set<Destination>([.iPhone, .iPad]),
                dependencies: [TargetDependency] = [.target(name: "SwissTransferCore"),
                                                    .target(name: "SwissTransferCoreUI")]) {
        self.name = name
        self.destinations = destinations
        self.dependencies = dependencies
    }

    public var asTarget: Target {
        .target(name: targetName,
                destinations: destinations,
                product: .framework,
                bundleId: "\(Constants.baseIdentifier).features.\(name)",
                deploymentTargets: Constants.deploymentTarget,
                infoPlist: .default,
                sources: "SwissTransferFeatures/\(name)/**",
                dependencies: dependencies,
                settings: .settings(base: Constants.baseSettings))
    }

    public var asDependency: TargetDependency {
        .target(name: targetName)
    }
}
