import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "MemoryDomain",
    product: .staticFramework,
    dependencies: [
        .Domain.BaseDomain
    ]
)
