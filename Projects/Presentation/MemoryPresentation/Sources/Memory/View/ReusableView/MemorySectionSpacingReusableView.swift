//
//  MemorySectionSpacingReusableView.swift
//  MemoryPresentation
//
//  Created by 선민재 on 8/19/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import DesignSystem

final class MemorySectionSpacingReusableView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = DesignSystemAsset.ColorAssests.backgroundNormal.color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
