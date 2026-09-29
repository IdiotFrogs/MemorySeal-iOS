//
//  VisitedScreenLogger.swift
//  ThridPartyLib
//
//  Created by 선민재 on 9/29/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

public enum VisitedScreenLogger {
    private static var isEnabled: Bool = false

    public static func enable() {
        guard !isEnabled else { return }
        isEnabled = true

        guard let original = class_getInstanceMethod(
            UIViewController.self,
            #selector(UIViewController.viewDidAppear(_:))
        ),
              let swizzled = class_getInstanceMethod(
                UIViewController.self,
                #selector(UIViewController.visitedScreenLogging_viewDidAppear(_:))
              )
        else { return }

        method_exchangeImplementations(original, swizzled)
    }
}

extension UIViewController {
    @objc fileprivate func visitedScreenLogging_viewDidAppear(_ animated: Bool) {
        visitedScreenLogging_viewDidAppear(animated)

        guard Bundle(for: type(of: self)) == Bundle.main else { return }

        AnalyticsLogger.log(.visitedScreen(screenName: String(describing: type(of: self))))
    }
}
