import UIKit
import SnapKit

import DesignSystem

final class PreviewPhotoMessageCell: UITableViewCell {

    static let identifier = String(describing: PreviewPhotoMessageCell.self)

    // MARK: - UI

    private let photoGridView: PreviewPhotoGridView = PreviewPhotoGridView()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        addSubviews()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    func configure(imageUrls: [String]) {
        photoGridView.configure(imageUrls: imageUrls)
    }
}

// MARK: - Subviews

extension PreviewPhotoMessageCell {
    private func addSubviews() {
        contentView.addSubview(photoGridView)
    }

    private func setLayout() {
        photoGridView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().inset(MyMessagesPreviewMetrics.contentSpacing)
            $0.trailing.equalToSuperview().inset(MyMessagesPreviewMetrics.feedTrailingInset)
            $0.width.equalTo(MyMessagesPreviewMetrics.contentColumnWidth)
        }
    }
}
