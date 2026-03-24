//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 3/17/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "CreateTicketData",
    product: .staticFramework,
    dependencies: [
        .Data.BaseData,
        .Domain.CreateTicketDomain
    ]
)
