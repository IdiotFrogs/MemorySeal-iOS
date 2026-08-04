//
//  TicketOpenView.swift
//  DesignSystem
//
//  Created by 선민재 on 8/4/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import Lottie
import Kingfisher

public final class TicketOpenView: UIView {

    // MARK: - Constant

    private enum Metric {
        static let canvasWidth: CGFloat = 308
        static let canvasHeight: CGFloat = 165
        static let bodySize: CGFloat = 269
        static let bodyLeadingOffset: CGFloat = 18.88
        static let bodyTopOffset: CGFloat = 136.26

        static let bodyLineWidth: CGFloat = 4
        static let bodyCornerRadius: CGFloat = 16
        static let bodyPadding: CGFloat = 24

        static let openedFrame: AnimationFrameTime = 10
        static let openAnimationEndFrame: AnimationFrameTime = 38
        static let frameRate: TimeInterval = 60
    }

    private enum Resource {
        static let animationName: String = "TicketOpen"
    }

    // MARK: - UI

    private let lidAnimationView: LottieAnimationView = {
        let animation = LottieAnimation.named(Resource.animationName, bundle: Bundle.module)
        let animationView = LottieAnimationView(animation: animation)
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.isUserInteractionEnabled = false
        return animationView
    }()

    private let bodyView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: .white,
            strokeColor: .black,
            lineWidth: Metric.bodyLineWidth
        )
        view.waveCornerRadius = Metric.bodyCornerRadius
        view.isUserInteractionEnabled = false
        return view
    }()

    private let photoView: TicketWavyPhotoView = {
        let view = TicketWavyPhotoView()
        view.isUserInteractionEnabled = false
        return view
    }()

    // MARK: - Properties

    public static let openAnimationDuration: TimeInterval =
        TimeInterval(Metric.openAnimationEndFrame) / Metric.frameRate

    public var ticketImage: UIImage? {
        get { photoView.image }
        set { photoView.image = newValue }
    }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: Metric.canvasWidth, height: Metric.bodyTopOffset + Metric.bodySize)
    }

    // MARK: - Init

    public init() {
        super.init(frame: .zero)

        backgroundColor = .clear
        clipsToBounds = false

        addSubviews()
        setLayout()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func addSubviews() {
        addSubview(bodyView)
        bodyView.addSubview(photoView)
        addSubview(lidAnimationView)
    }

    private func setLayout() {
        lidAnimationView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.width.equalTo(Metric.canvasWidth)
            $0.height.equalTo(Metric.canvasHeight)
        }

        bodyView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Metric.bodyTopOffset)
            $0.leading.equalToSuperview().offset(Metric.bodyLeadingOffset)
            $0.width.height.equalTo(Metric.bodySize)
            $0.bottom.equalToSuperview()
        }

        photoView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Metric.bodyPadding)
        }
    }

    // MARK: - Ticket Image

    public func setTicketImage(urlString: String?) {
        photoView.setImage(urlString: urlString)
    }

    // MARK: - Animation

    public func showClosedLid() {
        lidAnimationView.pause()
        lidAnimationView.currentFrame = 0
    }

    public func showOpenedLid() {
        lidAnimationView.pause()
        lidAnimationView.currentFrame = Metric.openedFrame
    }

    public func playOpenAnimation(completion: (() -> Void)? = nil) {
        lidAnimationView.loopMode = .playOnce
        lidAnimationView.play(
            fromFrame: 0,
            toFrame: Metric.openAnimationEndFrame,
            loopMode: .playOnce
        ) { _ in
            completion?()
        }
    }
}

// MARK: - TicketWavyPhotoView

private final class TicketWavyPhotoView: UIView {

    // MARK: - Constant

    private enum Metric {
        static let canvasWidth: CGFloat = 315
        static let canvasHeight: CGFloat = 317
        static let innerX: CGFloat = 16.83
        static let innerY: CGFloat = 18.04
        static let innerWidth: CGFloat = 281.1
        static let innerHeight: CGFloat = 280.27
        static let cornerRadius: CGFloat = 8
    }

    // MARK: - UI

    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        view.layer.cornerRadius = Metric.cornerRadius
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()

    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.ticketPeachPlaceholder.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()

    private let frameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.ticketWavyFrame.image
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    // MARK: - Properties

    var image: UIImage? {
        get { photoImageView.image }
        set {
            photoImageView.image = newValue
            photoImageView.isHidden = newValue == nil
            placeholderImageView.isHidden = newValue != nil
        }
    }

    // MARK: - Init

    init() {
        super.init(frame: .zero)

        backgroundColor = .clear

        addSubview(contentView)
        contentView.addSubview(placeholderImageView)
        contentView.addSubview(photoImageView)
        addSubview(frameImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds.width > 0, bounds.height > 0 else { return }

        frameImageView.frame = bounds

        let scaleX = bounds.width / Metric.canvasWidth
        let scaleY = bounds.height / Metric.canvasHeight
        contentView.frame = CGRect(
            x: Metric.innerX * scaleX,
            y: Metric.innerY * scaleY,
            width: Metric.innerWidth * scaleX,
            height: Metric.innerHeight * scaleY
        )
        placeholderImageView.frame = contentView.bounds
        photoImageView.frame = contentView.bounds
    }

    // MARK: - Image

    func setImage(urlString: String?) {
        guard let urlString, let url = URL(string: urlString) else {
            image = nil
            return
        }

        photoImageView.isHidden = false
        photoImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))]) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.placeholderImageView.isHidden = true
            case .failure:
                self.image = nil
            }
        }
    }
}
