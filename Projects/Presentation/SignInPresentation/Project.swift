//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 10/28/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "SignInPresentation",
    product: .staticFramework,
    dependencies: [
        .Domain.SignInDomain
    ],
    resources: ["Resources/**"]
)
