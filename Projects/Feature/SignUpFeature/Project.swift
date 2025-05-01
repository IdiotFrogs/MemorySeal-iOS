//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 4/13/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "SignUpFeature",
    product: .staticFramework,
    dependencies: [
        .Presentation.SignUpPresentation
    ]
)
