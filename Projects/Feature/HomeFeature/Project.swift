//
//  Project.swift
//  Manifests
//
//  Created by 선민재 on 5/19/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "HomeFeature",
    product: .staticFramework,
    dependencies: [
        .Presentation.HomePresentation
    ]
)
