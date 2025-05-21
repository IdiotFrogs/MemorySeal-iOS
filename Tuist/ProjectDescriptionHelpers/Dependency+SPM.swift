//
//  Dependency+SPM.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 9/26/24.
//

import ProjectDescription

public extension TargetDependency {
    enum SPM {}
}

public extension TargetDependency.SPM {
    static let RxSwift = TargetDependency.external(name: "RxSwift")
    static let RxCocoa = TargetDependency.external(name: "RxCocoa")
    static let Moya = TargetDependency.external(name: "Moya")
    static let Kingfisher = TargetDependency.external(name: "Kingfisher")
    static let SnapKit = TargetDependency.external(name: "SnapKit")
    static let Lottie = TargetDependency.external(name: "Lottie")
    static let Tabman = TargetDependency.external(name: "Tabman")
}
