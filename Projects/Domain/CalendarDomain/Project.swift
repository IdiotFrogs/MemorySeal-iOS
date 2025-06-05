//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 6/05/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "CalendarDomain",
    product: .staticFramework,
    dependencies: [
        .ThridPartyLib.ThridPartyLib
    ]
)
