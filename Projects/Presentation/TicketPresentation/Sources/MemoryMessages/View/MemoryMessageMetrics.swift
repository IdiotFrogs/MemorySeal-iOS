import UIKit

import DesignSystem

// MARK: - MemoryMessageMetrics

enum MemoryMessageMetrics {

    // MARK: Screen

    static let screenWidth: CGFloat = 375

    // MARK: Header

    static let navigationBarHeight: CGFloat = 56
    static let headerStackSpacing: CGFloat = 12
    static let headerBottomPadding: CGFloat = 16

    // MARK: Profile Bar

    static let profileBarSpacing: CGFloat = 12
    static let profileBarHorizontalInset: CGFloat = 20
    static let profileItemSpacing: CGFloat = 8

    static let focusedAvatarSize: CGFloat = 80
    static let focusedRingSize: CGFloat = 80
    static let focusedRingLineWidth: CGFloat = 2
    static let unfocusedAvatarSize: CGFloat = 60.25

    // MARK: Feed

    static let feedTopInset: CGFloat = 24
    static let feedLeftInset: CGFloat = 20
    static let feedRightInset: CGFloat = 8
    static let feedBottomInset: CGFloat = 24

    static let groupSpacing: CGFloat = 24
    static let intraGroupSpacing: CGFloat = 8

    static let feedAvatarSize: CGFloat = 24
    static let contentColumnWidth: CGFloat = 283

    static let bubbleCornerRadius: CGFloat = 20
    static let bubblePadding: CGFloat = 16

    static let photoCardSize: CGSize = CGSize(width: 283, height: 160)

    // MARK: Colors

    static let bubbleIncomingColor: UIColor = DesignSystemAsset.ColorAssests.backgroundNormal.color
    static let bubbleMineColor: UIColor = DesignSystemAsset.ColorAssests.primaryLight.color
    static let bodyTextColor: UIColor = DesignSystemAsset.ColorAssests.grey5.color
    static let nameTextColor: UIColor = DesignSystemAsset.ColorAssests.grey5.color
    static let titleTextColor: UIColor = DesignSystemAsset.ColorAssests.grey5.color
    static let focusRingColor: UIColor = DesignSystemAsset.ColorAssests.primaryNormal.color
    static let headerBorderColor: UIColor = DesignSystemAsset.ColorAssests.grey1.color
    static let photoPlaceholderColor: UIColor = UIColor(hex: "#D9D9D9") ?? UIColor(white: 0.85, alpha: 1)

    // MARK: Fonts

    static let titleFont: UIFont = DesignSystemFontFamily.Pretendard.bold.font(size: 20)
    static let focusedNameFont: UIFont = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
    static let unfocusedNameFont: UIFont = DesignSystemFontFamily.Pretendard.regular.font(size: 12)
    static let feedNameFont: UIFont = DesignSystemFontFamily.Pretendard.regular.font(size: 12)
    static let bodyFont: UIFont = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
    static let bodyLineHeightMultiple: CGFloat = 1.5
}
