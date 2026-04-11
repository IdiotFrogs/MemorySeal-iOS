import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "SplashFeature",
    product: .staticFramework,
    dependencies: [
        .Presentation.SplashPresentation,
        .Data.AuthData
    ]
)
