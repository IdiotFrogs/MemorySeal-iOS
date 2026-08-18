import UIKit

import DesignSystem

enum MyMessagesPreviewMetrics {

    // MARK: Header

    static let navigationBarHeight: CGFloat = 56

    // MARK: Guide Banner

    static let bannerHorizontalInset: CGFloat = 20
    static let bannerVerticalPadding: CGFloat = 12
    static let bannerContentHorizontalPadding: CGFloat = 20
    static let bannerContentVerticalPadding: CGFloat = 12
    static let bannerCornerRadius: CGFloat = 12
    static let bannerWaveSpacing: CGFloat = 6.0
    static let bannerWaveAmplitude: CGFloat = 2.0

    // MARK: Feed

    static let feedTopInset: CGFloat = 24
    static let feedBottomInset: CGFloat = 24
    static let feedTrailingInset: CGFloat = 12
    static let contentColumnWidth: CGFloat = 283
    static let contentSpacing: CGFloat = 8

    // MARK: Bubble

    static let bubbleCornerRadius: CGFloat = 20
    static let bubblePadding: CGFloat = 16

    // MARK: Photo

    static let photoRowHeight: CGFloat = 160
    static let photoCornerRadius: CGFloat = 20

    // MARK: Colors

    static let bannerBackgroundColor: UIColor = DesignSystemAsset.ColorAssests.backgroundNormal.color
    static let bannerTextColor: UIColor = DesignSystemAsset.ColorAssests.grey4.color
    static let bubbleColor: UIColor = DesignSystemAsset.ColorAssests.primaryLight.color
    static let bodyTextColor: UIColor = DesignSystemAsset.ColorAssests.grey5.color
    static let photoPlaceholderColor: UIColor = DesignSystemAsset.ColorAssests.grey1.color

    // MARK: Fonts

    static let titleFont: UIFont = DesignSystemFontFamily.Pretendard.bold.font(size: 20)
    static let bannerFont: UIFont = DesignSystemFontFamily.Pretendard.medium.font(size: 14)
    static let bodyFont: UIFont = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
    static let lineHeightRatio: CGFloat = 1.5
}

// MARK: - Attributed String

extension MyMessagesPreviewMetrics {
    static func attributedString(
        _ text: String,
        font: UIFont,
        color: UIColor,
        alignment: NSTextAlignment
    ) -> NSAttributedString {
        let lineHeight = (font.pointSize * lineHeightRatio).rounded()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight

        return NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle,
                .baselineOffset: (lineHeight - font.lineHeight) / 4
            ]
        )
    }
}
