//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 6/05/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "UserDomain",
    product: .staticFramework,
    dependencies: [
        .Domain.BaseDomain
    ]
)
