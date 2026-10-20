//
//  TutorialMetrics.swift
//  TutorialPresentation
//
//  Created by 선민재 on 10/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import DesignSystem

enum TutorialMetrics {

    // MARK: - Layout

    static let horizontalInset: CGFloat = 20
    static let skipTopOffset: CGFloat = 17
    static let contentTopOffset: CGFloat = 72
    static let textBlockHeight: CGFloat = 91
    static let illustrationBottomSpacing: CGFloat = 70
    static let indicatorBottomSpacing: CGFloat = 32
    static let titleToBodySpacing: CGFloat = 12
    static let bodyToButtonSpacing: CGFloat = 73

    // MARK: - Illustration

    static let illustrationWidth: CGFloat = 335
    static let illustrationHeight: CGFloat = 360

    // MARK: - Indicator

    static let indicatorDotSize: CGFloat = 6
    static let indicatorActiveWidth: CGFloat = 20
    static let indicatorSpacing: CGFloat = 6

    // MARK: - Button

    static let buttonHeight: CGFloat = 48
    static let buttonBottomInset: CGFloat = 20
    static let buttonCornerRadius: CGFloat = 12
    static let buttonLineWidth: CGFloat = 3

    // MARK: - Typography

    static let titleFont: UIFont = DesignSystemFontFamily.Pretendard.bold.font(size: 22)
    static let titleLineHeight: CGFloat = 22 * 1.4
    static let bodyFont: UIFont = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
    static let bodyLineHeight: CGFloat = 16 * 1.5
    static let skipFont: UIFont = DesignSystemFontFamily.Pretendard.medium.font(size: 14)
    static let buttonFont: UIFont = DesignSystemFontFamily.Pretendard.bold.font(size: 16)

    // MARK: - Color

    static let titleColor: UIColor = DesignSystemAsset.ColorAssests.grey5.color
    static let bodyColor: UIColor = DesignSystemAsset.ColorAssests.grey4.color
    static let skipColor: UIColor = DesignSystemAsset.ColorAssests.grey3.color
    static let indicatorActiveColor: UIColor = DesignSystemAsset.ColorAssests.primaryNormal.color
    static let indicatorInactiveColor: UIColor = DesignSystemAsset.ColorAssests.grey2.color
}
