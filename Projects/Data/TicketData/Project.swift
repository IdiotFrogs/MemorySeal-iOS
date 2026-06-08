import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "TicketData",
    product: .staticFramework,
    dependencies: [
        .Data.BaseData,
        .Domain.TicketDomain
    ]
)
