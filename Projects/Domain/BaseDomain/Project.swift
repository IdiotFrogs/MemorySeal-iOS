//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 9/26/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "BaseDomain",
    product: .staticFramework,
    dependencies: [
        .ThridPartyLib.ThridPartyLib,
        .Shared.DesignSystem
    ]
)
