//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 01/20/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "SignUpData",
    product: .staticFramework,
    dependencies: [
        .Data.BaseData,
        .Domain.SignUpDomain
    ]
)
