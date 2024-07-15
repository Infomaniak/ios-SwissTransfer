import Foundation
import ProjectDescription

public protocol Dependable {
    var asDependency: TargetDependency { get }
}

extension TargetDependency: Dependable {
    public var asDependency: TargetDependency {
        return self
    }
}

public extension [Feature] {
    var asTargets: [Target] {
        return map { $0.asTarget }
    }

    var asDependencies: [TargetDependency] {
        return map { $0.asDependency }
    }
}

public struct Feature: Dependable {
    let name: String
    var targetName: String {
        "ST\(name)"
    }

    let destinations: Set<Destination>
    let dependencies: [TargetDependency]
    let additionalDependencies: [TargetDependency]

    public init(name: String,
                destinations: Set<Destination> = Set<Destination>([.iPhone, .iPad]),
                dependencies: [Dependable] = [TargetDependency.target(name: "SwissTransferCore"),
                                              TargetDependency.target(name: "SwissTransferCoreUI")],
                additionalDependencies: [Dependable] = []) {
        self.name = name
        self.destinations = destinations
        self.dependencies = dependencies.map { $0.asDependency }
        self.additionalDependencies = additionalDependencies.map { $0.asDependency }
    }

    public var asTarget: Target {
        .target(name: targetName,
                destinations: destinations,
                product: .framework,
                bundleId: "\(Constants.baseIdentifier).features.\(name)",
                deploymentTargets: Constants.deploymentTarget,
                infoPlist: .default,
                sources: "SwissTransferFeatures/\(name)/**",
                dependencies: dependencies + additionalDependencies,
                settings: .settings(base: Constants.baseSettings))
    }

    public var asDependency: TargetDependency {
        .target(name: targetName)
    }
}
