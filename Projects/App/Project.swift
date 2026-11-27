import ProjectDescription
import ProjectDescriptionHelpers

let appTargetSettings: Settings = .settings(
    configurations: [
        .debug(
            name: .debug,
            settings: [
                "PRODUCT_BUNDLE_IDENTIFIER": "io.tuist.MemorySeal.dev",
                "APP_DISPLAY_NAME": "MemorySeal Dev",
                "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon-Dev",
                "BASE_URL": .string(Secrets.Dev.baseURL),
                "ATS_EXCEPTION_DOMAIN": .string(Secrets.Dev.serverHost),
                "GOOGLE_CLIENT_ID": .string(Secrets.Dev.googleClientID),
                "GOOGLE_REVERSED_CLIENT_ID": .string(Secrets.Dev.googleReversedClientID)
            ]
        ),
        .release(
            name: .release,
            settings: [
                "PRODUCT_BUNDLE_IDENTIFIER": "io.tuist.MemorySeal",
                "APP_DISPLAY_NAME": "MemorySeal",
                "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                "BASE_URL": .string(Secrets.Prod.baseURL),
                "GOOGLE_CLIENT_ID": .string(Secrets.Prod.googleClientID),
                "GOOGLE_REVERSED_CLIENT_ID": .string(Secrets.Prod.googleReversedClientID)
            ]
        )
    ]
)

let firebaseConfigScript: TargetScript = .post(
    script: """
    SOURCE="${SRCROOT}/Resources/Firebase/${CONFIGURATION}/GoogleService-Info.plist"
    DESTINATION="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/GoogleService-Info.plist"
    if [ ! -f "${SOURCE}" ]; then
        echo "error: ${SOURCE} 파일이 없습니다. ${CONFIGURATION} 환경의 GoogleService-Info.plist를 추가하세요."
        exit 1
    fi
    cp "${SOURCE}" "${DESTINATION}"
    """,
    name: "Copy GoogleService-Info.plist",
    inputPaths: ["$(SRCROOT)/Resources/Firebase/$(CONFIGURATION)/GoogleService-Info.plist"],
    outputPaths: ["$(BUILT_PRODUCTS_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist"],
    basedOnDependencyAnalysis: true
)

let atsExceptionScript: TargetScript = .post(
    script: """
    if [ -z "${ATS_EXCEPTION_DOMAIN}" ]; then
        exit 0
    fi
    PLIST="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
    ENTRY=":NSAppTransportSecurity:NSExceptionDomains:${ATS_EXCEPTION_DOMAIN}"
    /usr/libexec/PlistBuddy -c "Delete :NSAppTransportSecurity" "${PLIST}" 2>/dev/null || true
    /usr/libexec/PlistBuddy \\
        -c "Add :NSAppTransportSecurity dict" \\
        -c "Add :NSAppTransportSecurity:NSExceptionDomains dict" \\
        -c "Add ${ENTRY} dict" \\
        -c "Add ${ENTRY}:NSExceptionAllowsInsecureHTTPLoads bool true" \\
        -c "Add ${ENTRY}:NSIncludesSubdomains bool true" \\
        "${PLIST}"
    """,
    name: "Add ATS Exception Domain",
    inputPaths: ["$(TARGET_BUILD_DIR)/$(INFOPLIST_PATH)"],
    basedOnDependencyAnalysis: false
)

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
                    "CFBundleDisplayName": "$(APP_DISPLAY_NAME)",
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
                    "GIDClientID": "$(GOOGLE_CLIENT_ID)",
                    "BASE_URL": "$(BASE_URL)",
                    "CFBundleURLTypes": [
                        [
                            "CFBundleURLName": "GoogleSignIn",
                            "CFBundleURLSchemes": [
                                "$(GOOGLE_REVERSED_CLIENT_ID)"
                            ]
                        ]
                    ],
                    "UIBackgroundModes": [
                        "remote-notification"
                    ],
                ]
            ),
            sources: ["Sources/**"],
            resources: [
                .glob(pattern: "Resources/**", excluding: ["Resources/Firebase/**"])
            ],
            entitlements: "Sources/Support/memorySeal.entitlements",
            scripts: [firebaseConfigScript, atsExceptionScript],
            dependencies: [
                .Feature.AppFeature
            ],
            settings: appTargetSettings
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
