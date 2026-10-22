import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "TutorialFeature",
    product: .staticFramework,
    dependencies: [
        .Presentation.TutorialPresentation
    ]
)
