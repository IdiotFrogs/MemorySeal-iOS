import UIKit
import SnapKit
import Kingfisher

import DesignSystem

final class WateringDayCollectionViewCell: UICollectionViewCell {
    private let chipBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.isHidden = true
        return label
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
        photoImageView.layer.cornerRadius = photoImageView.bounds.width / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.kf.cancelDownloadTask()
        photoImageView.image = nil
        photoImageView.isHidden = true
        titleLabel.isHidden = true
    }

    func configure(with item: WateringDayItem) {
        chipBackgroundImageView.image = item.state.chipImage

        switch item.state {
        case .watered(let profileImageUrl):
            photoImageView.isHidden = false
            titleLabel.isHidden = true
            setProfileImage(urlString: profileImageUrl)
        case .today:
            photoImageView.isHidden = true
            titleLabel.isHidden = false
            titleLabel.text = "오늘"
            titleLabel.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
            titleLabel.textColor = DesignSystemAsset.ColorAssests.grey5.color
        case .upcoming(let day):
            photoImageView.isHidden = true
            titleLabel.isHidden = false
            titleLabel.text = "\(day)"
            titleLabel.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
            titleLabel.textColor = DesignSystemAsset.ColorAssests.grey3.color
        case .missed:
            photoImageView.isHidden = true
            titleLabel.isHidden = true
        }
    }

    private func setProfileImage(urlString: String?) {
        let placeholder = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        guard let urlString, let url = URL(string: urlString) else {
            photoImageView.image = placeholder
            return
        }
        photoImageView.kf.setImage(with: url, placeholder: placeholder)
    }
}

extension WateringDayCollectionViewCell {
    private func addSubviews() {
        contentView.addSubview(chipBackgroundImageView)
        contentView.addSubview(photoImageView)
        contentView.addSubview(titleLabel)
    }

    private func setLayout() {
        chipBackgroundImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(chipBackgroundImageView.snp.width)
        }

        photoImageView.snp.makeConstraints {
            $0.center.equalTo(chipBackgroundImageView)
            $0.width.height.equalTo(chipBackgroundImageView.snp.width).multipliedBy(0.53)
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
