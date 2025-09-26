//
//  Project.swift
//  Manifests
//
//  Created by 선민재 on 5/30/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "MessageListFeature",
    product: .staticFramework,
    dependencies: [
        .Presentation.MessageListPresentation
    ]
)
