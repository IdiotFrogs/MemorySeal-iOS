//
//  MemorySealCalendarCollectionViewCell.swift
//  DesignSystem
//
//  Created by 선민재 on 6/5/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

public final class MemorySealCalendarCollectionViewCell: UICollectionViewCell {
    private let dateButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(DesignSystemAsset.ColorAssests.grey5.color, for: .normal)
        button.setTitleColor(DesignSystemAsset.ColorAssests.grey2.color, for: .disabled)
        button.setTitleColor(.white, for: .selected)
        button.setBackgroundColor(color: .clear, forState: .normal)
        button.setBackgroundColor(color: .clear, forState: .disabled)
        button.setBackgroundColor(color: DesignSystemAsset.ColorAssests.primaryNormal.color, forState: .selected)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        button.layer.cornerRadius = 8
        button.isUserInteractionEnabled = false
        return button
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 8
        
        self.addSubviews()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        self.dateButton.setBackgroundColor(color: .clear, forState: .normal)
        self.isUserInteractionEnabled = true
    }
    
    override public var isSelected: Bool {
        didSet {
            dateButton.isSelected = isSelected
        }
    }
    
    public func configure(dateText: String, isCurrentMonth: Bool, isToday: Bool) {
        dateButton.setTitle(dateText, for: .normal)
        dateButton.isEnabled = isCurrentMonth
        
        if isCurrentMonth == false {
            isUserInteractionEnabled = false
        }
        
        if isToday {
            dateButton.setBackgroundColor(
                color: DesignSystemAsset.ColorAssests.grey1.color,
                forState: .normal
            )
        }
    }
}

extension MemorySealCalendarCollectionViewCell {
    private func addSubviews() {
        addSubview(dateButton)
    }
    
    private func setLayout() {
        dateButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
