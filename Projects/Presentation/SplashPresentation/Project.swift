import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "SplashPresentation",
    product: .staticFramework,
    dependencies: [
        .Domain.AuthDomain,
        .ThridPartyLib.ThridPartyLib,
        .Shared.DesignSystem
    ]
)
