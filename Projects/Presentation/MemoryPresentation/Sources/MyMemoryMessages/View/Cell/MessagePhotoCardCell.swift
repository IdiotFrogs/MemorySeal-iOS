import UIKit
import SnapKit
import DesignSystem

// MARK: - MessagePhotoCardCell

public final class MessagePhotoCardCell: UICollectionViewCell {
    public var onPreviewTap: (() -> Void)?

    private let thumbnailImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = DesignSystemAsset.ColorAssests.primaryLight.color
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.isUserInteractionEnabled = true
        return view
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setLayout()
        addTapGesture()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        onPreviewTap = nil
        thumbnailImageView.image = nil
    }

    public func configure(with message: MyMemoryMessage) {
        if let data = message.imageData, let image = UIImage(data: data) {
            thumbnailImageView.image = image
        }
    }

    @objc private func thumbnailTapped() {
        onPreviewTap?()
    }
}

// MARK: - Subviews

extension MessagePhotoCardCell {
    private func addSubviews() {
        contentView.addSubview(thumbnailImageView)
    }

    private func addTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(thumbnailTapped))
        thumbnailImageView.addGestureRecognizer(gesture)
    }
}

// MARK: - Layout

extension MessagePhotoCardCell {
    private func setLayout() {
        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(2)
        }
    }
}
