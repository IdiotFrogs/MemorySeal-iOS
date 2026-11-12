import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "MemorySeal",
    options: .options(
        defaultKnownRegions: ["ko"],
        developmentRegion: "ko"
    ),
    settings: .settings(
        base: [
            "DEVELOPMENT_TEAM": "5GD5Q99952",
            "OTHER_LDFLAGS": "-ObjC"
        ],
        configurations: [
            .debug(name: .debug),
            .release(name: .release)
        ]
    ),
    targets: [
        .target(
            name: "MemorySeal",
            destinations: [.iPhone],
            product: .app,
            bundleId: "io.tuist.MemorySeal",
            deploymentTargets: .memorySeal,
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName": "Default Configuration",
                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                                ],
                            ]
                        ]
                    ],
                    "GIDClientID": .string(Secrets.googleClientID),
                    "BASE_URL": .string(Secrets.baseURL),
                    "NSAppTransportSecurity": [
                        "NSExceptionDomains": [
                            Secrets.serverHost: [
                                "NSExceptionAllowsInsecureHTTPLoads": true,
                                "NSIncludesSubdomains": true
                            ]
                        ]
                    ],
                    "CFBundleURLTypes": [
                        [
                            "CFBundleURLName": "GoogleSignIn",
                            "CFBundleURLSchemes": [
                                .string(Secrets.googleReversedClientID)
                            ]
                        ]
                    ],
                    "UIBackgroundModes": [
                        "remote-notification"
                    ],
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: "Sources/Support/memorySeal.entitlements",
            dependencies: [
                .Feature.AppFeature
            ]
        ),
        .target(
            name: "MemorySealTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "io.tuist.MemorySealTests",
            deploymentTargets: .memorySeal,
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "MemorySeal")]
        ),
        .target(
            name: "MemorySealUITests",
            destinations: [.iPhone],
            product: .uiTests,
            bundleId: "io.tuist.MemorySealUITests",
            deploymentTargets: .memorySeal,
            infoPlist: .default,
            sources: ["UITests/**"],
            resources: [],
            dependencies: [.target(name: "MemorySeal")]
        ),
    ],
    schemes: [
        .scheme(
            name: "MemorySeal",
            shared: true,
            buildAction: .buildAction(targets: ["MemorySeal"]),
            testAction: .targets(
                ["MemorySealTests", "MemorySealUITests"],
                configuration: .debug
            ),
            runAction: .runAction(configuration: .debug),
            archiveAction: .archiveAction(configuration: .release),
            profileAction: .profileAction(configuration: .release),
            analyzeAction: .analyzeAction(configuration: .debug)
        )
    ]
)
