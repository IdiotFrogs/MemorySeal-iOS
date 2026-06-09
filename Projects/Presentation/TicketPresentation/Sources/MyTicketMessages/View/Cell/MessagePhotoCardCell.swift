import UIKit
import SnapKit
import Kingfisher

import DesignSystem

// MARK: - MessagePhotoCardCell

public final class MessagePhotoCardCell: UICollectionViewCell {

    private let thumbnailImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = DesignSystemAsset.ColorAssests.primaryLight.color
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()

    private let selectionBorderView: WavyStrokeView = {
        let view = WavyStrokeView(
            style: .stroked(
                color: DesignSystemAsset.ColorAssests.primaryNormal.color,
                lineWidth: 4
            )
        )
        view.waveCornerRadius = 14
        view.strokeAlignment = .outside
        view.isHidden = true
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }()

    private let selectionIconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setLayout()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.kf.cancelDownloadTask()
        thumbnailImageView.image = nil
        selectionIconView.isHidden = true
        selectionIconView.image = nil
        selectionBorderView.isHidden = true
    }

    public func configure(with imageUrl: String) {
        let url = URL(string: imageUrl)
        thumbnailImageView.kf.setImage(with: url)
    }

    public func setSelection(isSelectionMode: Bool, isSelected: Bool) {
        selectionIconView.isHidden = !isSelectionMode
        selectionBorderView.isHidden = !(isSelectionMode && isSelected)
        guard isSelectionMode else {
            selectionIconView.image = nil
            return
        }
        let name = isSelected ? "PhotoSelectedIcon" : "PhotoUnselectedIcon"
        selectionIconView.image = UIImage(
            named: name,
            in: DesignSystemResources.bundle,
            with: nil
        )
    }
}

// MARK: - Subviews

extension MessagePhotoCardCell {
    private func addSubviews() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(selectionBorderView)
        contentView.addSubview(selectionIconView)
    }
}

// MARK: - Layout

extension MessagePhotoCardCell {
    private func setLayout() {
        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }
        selectionBorderView.snp.makeConstraints {
            $0.edges.equalTo(thumbnailImageView)
        }
        selectionIconView.snp.makeConstraints {
            $0.top.leading.equalTo(thumbnailImageView).inset(10)
            $0.size.equalTo(16)
        }
    }
}
