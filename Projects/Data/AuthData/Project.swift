//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 01/20/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "AuthData",
    product: .staticFramework,
    dependencies: [
        .Domain.AuthDomain,
        .Data.BaseData
    ]
)
