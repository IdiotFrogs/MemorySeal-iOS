import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "HomeData",
    product: .staticFramework,
    dependencies: [
        .Data.BaseData,
        .Domain.HomeDomain
    ]
)
