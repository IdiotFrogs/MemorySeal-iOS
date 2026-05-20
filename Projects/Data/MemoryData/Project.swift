import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "MemoryData",
    product: .staticFramework,
    dependencies: [
        .Data.BaseData,
        .Domain.MemoryDomain
    ]
)
