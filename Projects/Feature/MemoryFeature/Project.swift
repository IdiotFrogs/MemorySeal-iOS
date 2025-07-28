//
//  Project.swift
//  Manifests
//
//  Created by 선민재 on 7/28/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "MemoryFeature",
    product: .staticFramework,
    dependencies: [
        .Presentation.MemoryPresentation
    ]
)
