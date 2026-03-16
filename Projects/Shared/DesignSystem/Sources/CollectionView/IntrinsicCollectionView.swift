//
//  IntrinsicCollectionView.swift
//  DesignSystem
//
//  Created by 선민재 on 3/15/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

public final class IntrinsicCollectionView: UICollectionView {
    public override var contentSize: CGSize {
        didSet { invalidateIntrinsicContentSize() }
    }

    public override var intrinsicContentSize: CGSize {
        return contentSize
    }
}
