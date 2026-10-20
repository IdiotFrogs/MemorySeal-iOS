import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "TutorialPresentation",
    product: .staticFramework,
    dependencies: [
        .Domain.BaseDomain
    ]
)
