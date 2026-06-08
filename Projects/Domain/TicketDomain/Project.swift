import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "TicketDomain",
    product: .staticFramework,
    dependencies: [
        .Domain.BaseDomain
    ]
)
