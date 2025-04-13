//
//  OAuthButton.swift
//  LoginFeature
//
//  Created by 선민재 on 10/29/24.
//  Copyright © 2024 MinSungJin. All rights reserved.
//

import UIKit
import SnapKit

import DesignSystem

final class OAuthButton: UIButton {
    struct ButtonStyle {
        let title: String
        let symbolImage: UIImage
        let titleColor: UIColor
        let backgroundColor: UIColor
    }
    
    enum OAuthType: String {
        case google
        
        var buttonStyle: ButtonStyle {
            switch self {
            case .google:
                return ButtonStyle(
                    title: "Google로 로그인",
                    symbolImage: DesignSystemAsset.ImageAssets.googleSymbol.image,
                    titleColor: UIColor(hex: "#121212") ?? .black,
                    backgroundColor: .white
                )
            }
        }
    }
    
    private let oauthTitleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 16)
        return label
    }()
    
    private let oauthImageView = UIImageView()
    
    init(oauthType: OAuthType) {
        super.init(frame: .zero)
        self.layer.cornerRadius = 10
        
        self.setView(oauthType)
        self.addSubViews()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OAuthButton {
    
    private func setView(_ oauthType: OAuthType) {
        oauthTitleLabel.text = oauthType.buttonStyle.title
        oauthTitleLabel.tintColor = oauthType.buttonStyle.titleColor
        oauthImageView.image = oauthType.buttonStyle.symbolImage
        backgroundColor = oauthType.buttonStyle.backgroundColor
        layer.cornerRadius = 24
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
    
    private func addSubViews() {
        addSubview(oauthTitleLabel)
        addSubview(oauthImageView)
    }
    
    private func setLayout() {
        oauthTitleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        oauthImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(16)
            $0.width.height.equalTo(24)
        }
    }
}
