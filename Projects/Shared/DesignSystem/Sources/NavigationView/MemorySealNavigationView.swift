//
//  MemorySealNavigationView.swift
//  DesignSystem
//
//  Created by 선민재 on 5/30/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

public final class MemorySealNavigationView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(
            DesignSystemAsset.ImageAssets.navigationBarBackButton.image,
            for: .normal
        )
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    public var backButtonDidTap: ControlEvent<Void> {
        return backButton.rx.tap
    }
    
    public func setTitle(_ text: String?) {
        titleLabel.text = text
    }
    
    public func addButton(_ button: UIButton) {
        buttonStackView.addArrangedSubview(button)
    }
    
    public init() {
        super.init(frame: .zero)
        
        self.addSubviews()
        self.setLayout()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MemorySealNavigationView {
    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(backButton)
        addSubview(buttonStackView)
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        backButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(24)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
}
