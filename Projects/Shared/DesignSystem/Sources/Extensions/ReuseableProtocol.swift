//
//  ReuseableProtocol.swift
//  DesignSystem
//
//  Created by 선민재 on 5/26/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit

protocol ReusableProtocol: AnyObject {
    static var reuseIdentifier: String { get }
}

extension UIViewController: ReusableProtocol {
    static public var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableProtocol {
    static public var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell: ReusableProtocol {
    static public var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewHeaderFooterView: ReusableProtocol {
    static public var reuseIdentifier: String {
        return String(describing: self)
    }
}
