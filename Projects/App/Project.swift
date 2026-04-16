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
                    "GIDClientID": "502710482304-3l8hdi5q9917det47g5i8e4fjj53fr5o.apps.googleusercontent.com",
                    "NSAppTransportSecurity": [
                        "NSExceptionDomains": [
                            "43.201.236.253": [
                                "NSExceptionAllowsInsecureHTTPLoads": true,
                                "NSIncludesSubdomains": true
                            ]
                        ]
                    ],
                    "CFBundleURLTypes": [
                        [
                            "CFBundleURLName": "GoogleSignIn",
                            "CFBundleURLSchemes": [
                                "com.googleusercontent.apps.502710482304-3l8hdi5q9917det47g5i8e4fjj53fr5o"
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
