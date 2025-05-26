//
//  TextButton.swift
//  DesignSystem
//
//  Created by 선민재 on 5/26/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

public final class TextButton: UIButton {
    private let titleInsets: UIEdgeInsets
        
    private let textLabel = UILabel()
        
    override public func setTitle(
        _ title: String?,
        for state: UIControl.State
    ) {
        textLabel.text = title
    }
    
    override public func setTitleColor(
        _ color: UIColor?,
        for state: UIControl.State
    ) {
        textLabel.textColor = color
    }
    
    public func setFont(
        _ font: UIFont
    ) {
        textLabel.font = font
    }
    
    public func setTextAlignment(
        _ textAlignment: NSTextAlignment
    ) {
        textLabel.textAlignment = textAlignment
    }

    public init(
        titleInsets: UIEdgeInsets
    ) {
        self.titleInsets = titleInsets
        super.init(frame: .zero)
        
        self.addSubviews()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TextButton {
    private func addSubviews() {
        addSubview(textLabel)
    }
    
    private func setLayout() {
        textLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(titleInsets.top)
            $0.bottom.equalToSuperview().offset(titleInsets.bottom)
            $0.leading.equalToSuperview().offset(titleInsets.left)
            $0.trailing.equalToSuperview().offset(titleInsets.right)
        }
    }
}
