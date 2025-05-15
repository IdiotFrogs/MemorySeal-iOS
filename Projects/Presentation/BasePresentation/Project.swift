//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 9/26/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "BasePresentation",
    product: .staticFramework,
    dependencies: [
        .Domain.BaseDomain,
        .ThridPartyLib.ThridPartyLib,
        .Shared.DesignSystem
    ],
    resources: ["Resources/**"]
)
