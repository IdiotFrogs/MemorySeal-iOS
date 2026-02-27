//
//  Dependency+Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 9/26/24.
//

import ProjectDescription

extension TargetDependency {
    public enum Data {}
    public enum Domain {}
    public enum Presentation {}
    public enum Feature {}
    public enum ThridPartyLib {}
    public enum Shared {}
}

public extension TargetDependency.Data {
    //MARK: - Data
    static let BaseData = TargetDependency.project(
        target: "BaseData",
        path: .relativeToRoot("Projects/Data/BaseData")
    )
    
    static let AuthData = TargetDependency.project(
        target: "AuthData",
        path: .relativeToRoot("Projects/Data/AuthData")
    )
    
    static let UserData = TargetDependency.project(
        target: "UserData",
        path: .relativeToRoot("Projects/Data/UserData")
    )
}

public extension TargetDependency.Domain {
    //MARK: - Domain
    static let BaseDomain = TargetDependency.project(
        target: "BaseDomain",
        path: .relativeToRoot("Projects/Domain/BaseDomain")
    )
    
    static let CalendarDomain = TargetDependency.project(
        target: "CalendarDomain",
        path: .relativeToRoot("Projects/Domain/CalendarDomain")
    )
    
    static let AuthDomain = TargetDependency.project(
        target: "AuthDomain",
        path: .relativeToRoot("Projects/Domain/AuthDomain")
    )
    
    static let UserDomain = TargetDependency.project(
        target: "UserDomain",
        path: .relativeToRoot("Projects/Domain/UserDomain")
    )
}

public extension TargetDependency.Feature {
    //MARK: - Feature
    static let AppFeature = TargetDependency.project(
        target: "AppFeature",
        path: .relativeToRoot("Projects/Feature/AppFeature")
    )
    
    static let SignUpFeature = TargetDependency.project(
        target: "SignUpFeature",
        path: .relativeToRoot("Projects/Feature/SignUpFeature")
    )
    
    static let AuthFeature = TargetDependency.project(
        target: "AuthFeature",
        path: .relativeToRoot("Projects/Feature/AuthFeature")
    )
    
    static let HomeFeature = TargetDependency.project(
        target: "HomeFeature",
        path: .relativeToRoot("Projects/Feature/HomeFeature")
    )
    
    static let CreateTicketFeature = TargetDependency.project(
        target: "CreateTicketFeature",
        path: .relativeToRoot("Projects/Feature/CreateTicketFeature")
    )
    
    static let ProfileFeature = TargetDependency.project(
        target: "ProfileFeature",
        path: .relativeToRoot("Projects/Feature/ProfileFeature")
    )
    
    static let MemoryFeature = TargetDependency.project(
        target: "MemoryFeature",
        path: .relativeToRoot("Projects/Feature/MemoryFeature")
    )
}

public extension TargetDependency.Presentation {
    //MARK: - Presentation
    static let BasePresentation = TargetDependency.project(
        target: "BasePresentation",
        path: .relativeToRoot("Projects/Presentation/BasePresentation")
    )
    
    static let AuthPresentation = TargetDependency.project(
        target: "AuthPresentation",
        path: .relativeToRoot("Projects/Presentation/AuthPresentation")
    )
    
    static let SignUpPresentation = TargetDependency.project(
        target: "SignUpPresentation",
        path: .relativeToRoot("Projects/Presentation/SignUpPresentation")
    )
    
    static let HomePresentation = TargetDependency.project(
        target: "HomePresentation",
        path: .relativeToRoot("Projects/Presentation/HomePresentation")
    )
    
    static let CreateTicketPresentation = TargetDependency.project(
        target: "CreateTicketPresentation",
        path: .relativeToRoot("Projects/Presentation/CreateTicketPresentation")
    )
    
    static let ProfilePresentation = TargetDependency.project(
        target: "ProfilePresentation",
        path: .relativeToRoot("Projects/Presentation/ProfilePresentation")
    )
    
    static let MemoryPresentation = TargetDependency.project(
        target: "MemoryPresentation",
        path: .relativeToRoot("Projects/Presentation/MemoryPresentation")
    )
}

public extension TargetDependency.ThridPartyLib {
    //MARK: - ThirdPartyLib
    static let ThridPartyLib = TargetDependency.project(
        target: "ThridPartyLib",
        path: .relativeToRoot("Projects/ThridPartyLib")
    )
}
    

public extension TargetDependency.Shared {
    //MARK: - Util
    static let DesignSystem = TargetDependency.project(
        target: "DesignSystem",
        path: .relativeToRoot("Projects/Shared/DesignSystem")
    )
    
    static let Util = TargetDependency.project(
        target: "Util",
        path: .relativeToRoot("Projects/Shared/Util")
    )
}
