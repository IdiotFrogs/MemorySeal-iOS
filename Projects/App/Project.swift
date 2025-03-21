import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "MemorySeal",
    options: .options(
        defaultKnownRegions: ["ko"],
        developmentRegion: "ko"
    ),
    settings: .settings(
        base: ["DEVELOPMENT_TEAM": "5GD5Q99952"],
        configurations: [
            .debug(name: .debug),
            .release(name: .release)
        ]
    ),
    targets: [
        .target(
            name: "MemorySeal",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.MemorySeal",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
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
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: "Sources/Support/memorySeal.entitlements",
            dependencies: [
                .DIContainer.BaseDIContainer
            ]
        ),
        .target(
            name: "MemorySealTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.MemorySealTests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "MemorySeal")]
        ),
    ]
)
