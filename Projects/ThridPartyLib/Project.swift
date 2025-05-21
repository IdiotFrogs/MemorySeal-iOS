//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 9/26/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "ThridPartyLib",
    product: .staticFramework,
    dependencies: [
        .SPM.RxSwift,
        .SPM.RxCocoa,
        .SPM.Moya,
        .SPM.Kingfisher,
        .SPM.SnapKit,
        .SPM.Lottie,
        .SPM.Tabman
    ]
)
