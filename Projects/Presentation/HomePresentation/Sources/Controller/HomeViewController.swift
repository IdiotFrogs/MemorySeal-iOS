//
//  HomeViewController.swift
//  SplashFeature
//
//  Created by 선민재 on 5/19/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class HomeViewController: UIViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.cyan
        
        self.addSubViews()
        self.setLayout()
        
        self.bindButtons()
    }
}

extension HomeViewController {
    private func bindButtons() {
        
    }
}

extension HomeViewController {
    private func addSubViews() {
        
    }
    
    private func setLayout() {
        
    }
}
