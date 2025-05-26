//
//  TicketCollectionViewCell.swift
//  HomePresentation
//
//  Created by 선민재 on 5/26/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

final class TicketCollectionViewCell: UICollectionViewCell {
    private let ticketHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let endDateLabel: UILabel = {
        let label = UILabel()
        label.text = "D-5"
        label.textColor = .black
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 32)
        return label
    }()
    
    private let ticketCreatedAtLabel: UILabel = {
        let label = UILabel()
        label.text = "2025.05.25"
        label.textColor = DesignSystemAsset.ColorAssests.grey4.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
        return label
    }()
    
    private let dotLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let ticketContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let ticketTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "제목입니다."
        label.textColor = .black
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        return label
    }()
    
    private let ticketImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.ticketDummyImage.image
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubviews()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.dotLineView.layoutIfNeeded()
        
        self.setLineDot(
            view: dotLineView,
            color: DesignSystemAsset.ColorAssests.grey2.color
        )
    }
}

extension TicketCollectionViewCell {
    private func setLineDot(
        view: UIView,
        color: UIColor
    ){
        view.layer.sublayers?
            .filter { $0 is CAShapeLayer }
            .forEach { $0.removeFromSuperlayer() }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [6, 6]
        shapeLayer.lineCap = .round
        
        let path = CGMutablePath()
        path.addLines(between: [
            CGPoint(x: 0, y: view.bounds.midY),
            CGPoint(x: view.bounds.width, y: view.bounds.midY)
        ])
        shapeLayer.path = path
        
        view.layer.addSublayer(shapeLayer)
    }
}

extension TicketCollectionViewCell {
    private func addSubviews() {
        contentView.addSubview(ticketHeaderView)
        ticketHeaderView.addSubview(endDateLabel)
        ticketHeaderView.addSubview(ticketCreatedAtLabel)
        contentView.addSubview(dotLineView)
        
        contentView.addSubview(ticketContentView)
        ticketContentView.addSubview(ticketTitleLabel)
        ticketContentView.addSubview(ticketImageView)
    }
    
    private func setLayout() {
        ticketHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        endDateLabel.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview().inset(16)
        }
        
        ticketCreatedAtLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
        }
        
        dotLineView.snp.makeConstraints {
            $0.top.equalTo(ticketHeaderView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(2)
        }
        
        ticketContentView.snp.makeConstraints {
            $0.top.equalTo(dotLineView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        ticketTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(16)
        }
        
        ticketImageView.snp.makeConstraints {
            $0.top.equalTo(ticketTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }
}
