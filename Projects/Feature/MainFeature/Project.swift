//
//  Project.swift
//  Manifests
//
//  Created by 선민재 on 4/13/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "MainFeature",
    product: .staticFramework,
    dependencies: [
        .Feature.HomeFeature,
        .Feature.ProfileFeature,
        .Feature.CreateTicketFeature,
        .Feature.MemoryFeature
    ]
)
