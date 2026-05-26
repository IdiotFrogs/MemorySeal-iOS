import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "HomeDomain",
    product: .staticFramework,
    dependencies: [
        .Domain.BaseDomain
    ]
)
