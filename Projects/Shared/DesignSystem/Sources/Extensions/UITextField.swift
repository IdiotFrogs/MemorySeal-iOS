//
//  UITextField.swift
//  DesignSystem
//
//  Created by 선민재 on 5/30/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit

public extension UITextField {
    func setPlaceholder(
        color: UIColor,
        font: UIFont
    ) {
        guard let string = self.placeholder else { return }
        attributedPlaceholder = NSAttributedString(
            string: string,
            attributes: [
                .foregroundColor: color,
                .font: font
            ]
        )
    }
}
