//
//  VoiceMemoryCollectionViewCell.swift
//  MemoryPresentation
//
//  Created by 선민재 on 8/12/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import DesignSystem

public final class VoiceMemoryCollectionViewCell: UICollectionViewCell {
    private let playVoiceButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setImage(
            DesignSystemAsset.ImageAssets.playIcon.image,
            for: .normal
        )
        button.layer.cornerRadius = 20
        return button
    }()
    
    private let waveformView: BarWaveformView = {
        let waveformView = BarWaveformView()
        waveformView.backgroundColor = .clear
        return waveformView
    }()
    
    private let playTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "0:02"
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 12)
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setView()
        self.addSubviews()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VoiceMemoryCollectionViewCell {
    func configure(_ url : URL) {        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("다운로드 실패: \(error)")
                return
            }
            guard let data = data else { return }
            
            // 캐시 폴더에 저장
            let fileManager = FileManager.default
            let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let localURL = caches.appendingPathComponent("cached_audio.m4a")
            
            do {
                try data.write(to: localURL)
                print("캐시에 파일 저장 완료: \(localURL)")
            } catch {
                print("캐시 저장 실패: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                self.waveformView.loadAudio(url: localURL)
            }
        }
        task.resume()
    }
//    
//    private func saveDownloadedFile(from location: URL, filename: String) -> URL? {
//        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
//        let destination = caches.appendingPathComponent(filename)
//        
//        try? FileManager.default.removeItem(at: destination) // 기존 파일 있으면 삭제
//        do {
//            try FileManager.default.moveItem(at: location, to: destination)
//            return destination
//        } catch {
//            print("파일 저장 실패:", error)
//            return nil
//        }
//    }
}

extension VoiceMemoryCollectionViewCell {
    private func setView() {
        backgroundColor = DesignSystemAsset.ColorAssests.primaryLight.color
        layer.cornerRadius = 20
    }
    
    private func addSubviews() {
        addSubview(playVoiceButton)
        addSubview(playTimeLabel)
        addSubview(waveformView)
    }
    
    private func setLayout() {
        playVoiceButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().offset(8)
            $0.width.height.equalTo(40)
        }
        
        playTimeLabel.snp.makeConstraints {
            $0.centerY.equalTo(playVoiceButton.snp.centerY)
            $0.trailing.equalToSuperview().inset(8)
        }
        
        waveformView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.equalTo(playVoiceButton.snp.trailing).offset(8)
            $0.trailing.equalTo(playTimeLabel.snp.leading).offset(-8)
        }
    }
}
