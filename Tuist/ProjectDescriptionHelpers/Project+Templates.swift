import ProjectDescription

public extension DeploymentTargets {
    static let memorySeal: DeploymentTargets = .iOS("18.0")
}

public extension Project {
    static func makeModule(
        name: String,
        destinations: Destinations = [.iPhone],
        deploymentTargets: DeploymentTargets = .memorySeal,
        product: Product,
        organizationName: String = "MemorySeal",
        packages: [Package] = [],
        dependencies: [TargetDependency] = [],
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        infoPlist: InfoPlist = .default,
        resourceSynthesizers: [ResourceSynthesizer] = .default
    ) -> Project {
        let settings: Settings = .settings(
            base: ["DEVELOPMENT_TEAM" : "5GD5Q99952"],
            configurations: [
                .debug(name: .debug),
                .release(name: .release)
            ])

        let appTarget: Target = .target(
            name: name,
            destinations: destinations,
            product: product,
            bundleId: "\(organizationName).\(name)",
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            dependencies: dependencies
        )

        let testTarget: Target = .target(
            name: "\(name)Tests",
            destinations: destinations,
            product: .unitTests,
            bundleId: "\(organizationName).\(name)Tests",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [.target(name: name)]
        )

        let schemes: [Scheme] = [
            .makeScheme(target: .debug, name: name),
            .makeScheme(target: .release, name: name)
        ]

        let targets: [Target] = [appTarget, testTarget]

        return Project(
            name: name,
            organizationName: organizationName,
            options: .options(
                defaultKnownRegions: ["ko"],
                developmentRegion: "ko"
            ),
            packages: packages,
            settings: settings,
            targets: targets,
            schemes: schemes,
            resourceSynthesizers: resourceSynthesizers
        )
    }
}

extension Scheme {
    static func makeScheme(target: ConfigurationName, name: String) -> Scheme {
        let scheme: Scheme = .scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: ["\(name)"]),
            testAction: .targets(
                ["\(name)Tests"],
                configuration: target,
                options: .options(coverage: true, codeCoverageTargets: ["\(name)"])
            ),
            runAction: .runAction(configuration: target),
            archiveAction: .archiveAction(configuration: target),
            profileAction: .profileAction(configuration: target),
            analyzeAction: .analyzeAction(configuration: target)
        )
        return scheme
    }
}

