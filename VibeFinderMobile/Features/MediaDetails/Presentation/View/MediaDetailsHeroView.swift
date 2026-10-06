import UIKit

final class MediaDetailsHeroView: UIView {
    private enum ArtworkMetrics {
        static let gameTopInset: CGFloat = 48
        static let gameTopFadeRatio: CGFloat = 0.22
        static let gameBottomFadeRatio: CGFloat = 0.30
        static let standardLandscapeBottomFadeRatio: CGFloat = 0.48
        static let standardBottomFadeRatio: CGFloat = 0.58
    }

    private let imageLoader: RemoteImageLoading
    private var imageTask: URLSessionDataTask?
    private var representedURL: URL?

    private let posterView = UIView()
    private let posterImageView = UIImageView()
    private var posterImageTopConstraint: NSLayoutConstraint?
    private var posterImageHeightConstraint: NSLayoutConstraint?
    private var posterHeightConstraint: NSLayoutConstraint?
    private let fallbackIconView = UIImageView()
    private let fallbackGradient = CAGradientLayer()
    private let topFadeView = MediaDetailsPosterFadeView(edge: .top)
    private let posterFadeView = MediaDetailsPosterFadeView()
    private var fadeBottomConstraint: NSLayoutConstraint?
    private var fadeHeightConstraint: NSLayoutConstraint?
    private var safeAreaTopInset: CGFloat = 0
    private var artworkStartsBelowSafeArea = false

    private let mediaTypeLabel = PaddedLabel()
    private let titleLabel = UILabel()
    private let originalTitleLabel = UILabel()
    private let yearLabel = PaddedLabel()
    private let ratingLabel = PaddedLabel()
    private let metadataStack = UIStackView()
    private let informationStack = UIStackView()

    init(imageLoader: RemoteImageLoading) {
        self.imageLoader = imageLoader
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        imageTask?.cancel()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        fallbackGradient.frame = posterView.bounds
    }

    func updateSafeAreaTopInset(_ inset: CGFloat) {
        guard safeAreaTopInset != inset else { return }
        safeAreaTopInset = inset
        updateArtworkTopInset()
    }

    func configure(with model: MediaDetailsDisplayModel) {
        mediaTypeLabel.text = model.mediaType.uppercased()
        titleLabel.text = model.title
        originalTitleLabel.text = model.originalTitle.map {
            "\(L10n.Media.Details.originalTitle): \($0)"
        }
        originalTitleLabel.isHidden = model.originalTitle == nil
        yearLabel.text = model.releaseYear
        yearLabel.isHidden = model.releaseYear == nil
        ratingLabel.text = model.rating
        ratingLabel.isHidden = model.rating == nil
        metadataStack.isHidden = model.releaseYear == nil && model.rating == nil

        imageTask?.cancel()
        representedURL = model.imageURL
        posterImageView.image = nil
        artworkStartsBelowSafeArea = model.artworkStartsBelowSafeArea
        updateArtworkTopInset()
        setPosterImage(nil)
        fallbackIconView.image = UIImage(systemName: model.fallbackSymbol)
        fallbackIconView.isHidden = false
        imageTask = imageLoader.loadImage(from: model.imageURL) { [weak self] image in
            guard let self, self.representedURL == model.imageURL else { return }
            self.setPosterImage(image)
            self.fallbackIconView.isHidden = image != nil
        }
    }

    private func configure() {
        backgroundColor = AppTheme.Color.background
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) {
            (view: MediaDetailsHeroView, _) in
            view.updateFallbackColors()
        }
        configurePoster()
        configureInformation()

        [posterView, informationStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        let preferredHeight = posterView.heightAnchor.constraint(
            equalTo: posterView.widthAnchor,
            multiplier: 1.4
        )
        preferredHeight.priority = .defaultHigh
        posterHeightConstraint = preferredHeight

        NSLayoutConstraint.activate([
            posterView.topAnchor.constraint(equalTo: topAnchor),
            posterView.leadingAnchor.constraint(equalTo: leadingAnchor),
            posterView.trailingAnchor.constraint(equalTo: trailingAnchor),
            preferredHeight,
            posterView.heightAnchor.constraint(greaterThanOrEqualToConstant: 220),
            posterView.heightAnchor.constraint(lessThanOrEqualToConstant: 620),

            informationStack.topAnchor.constraint(equalTo: posterView.bottomAnchor, constant: -32),
            informationStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            informationStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            informationStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            titleLabel.widthAnchor.constraint(equalTo: informationStack.widthAnchor),
            originalTitleLabel.widthAnchor.constraint(equalTo: informationStack.widthAnchor)
        ])
        setPosterImage(nil)
    }

    private func configurePoster() {
        posterView.backgroundColor = AppTheme.Color.background
        posterView.clipsToBounds = true

        updateFallbackColors()
        fallbackGradient.startPoint = CGPoint(x: 0, y: 0)
        fallbackGradient.endPoint = CGPoint(x: 1, y: 1)
        posterView.layer.addSublayer(fallbackGradient)

        posterImageView.contentMode = .scaleToFill
        posterImageView.clipsToBounds = true
        fallbackIconView.tintColor = AppTheme.Color.textPrimary.withAlphaComponent(0.52)
        fallbackIconView.contentMode = .scaleAspectFit

        [posterImageView, fallbackIconView, topFadeView, posterFadeView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            posterView.addSubview($0)
        }
        topFadeView.isHidden = true

        let preferredTopFadeHeight = topFadeView.heightAnchor.constraint(
            equalTo: posterImageView.heightAnchor,
            multiplier: ArtworkMetrics.gameTopFadeRatio
        )
        preferredTopFadeHeight.priority = .defaultHigh

        let initialFadeBottom = posterFadeView.bottomAnchor.constraint(equalTo: posterView.bottomAnchor)
        let initialFadeHeight = posterFadeView.heightAnchor.constraint(
            equalTo: posterView.heightAnchor,
            multiplier: ArtworkMetrics.standardBottomFadeRatio
        )
        fadeBottomConstraint = initialFadeBottom
        fadeHeightConstraint = initialFadeHeight

        let imageTop = posterImageView.topAnchor.constraint(equalTo: posterView.topAnchor)
        posterImageTopConstraint = imageTop

        NSLayoutConstraint.activate([
            imageTop,
            posterImageView.leadingAnchor.constraint(equalTo: posterView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: posterView.trailingAnchor),

            fallbackIconView.centerXAnchor.constraint(equalTo: posterView.centerXAnchor),
            fallbackIconView.centerYAnchor.constraint(equalTo: posterView.centerYAnchor, constant: -36),
            fallbackIconView.widthAnchor.constraint(equalToConstant: 86),
            fallbackIconView.heightAnchor.constraint(equalTo: fallbackIconView.widthAnchor),

            topFadeView.topAnchor.constraint(equalTo: posterImageView.topAnchor),
            topFadeView.leadingAnchor.constraint(equalTo: posterView.leadingAnchor),
            topFadeView.trailingAnchor.constraint(equalTo: posterView.trailingAnchor),
            preferredTopFadeHeight,
            topFadeView.heightAnchor.constraint(lessThanOrEqualToConstant: 100),

            posterFadeView.leadingAnchor.constraint(equalTo: posterView.leadingAnchor),
            posterFadeView.trailingAnchor.constraint(equalTo: posterView.trailingAnchor),
            initialFadeBottom,
            initialFadeHeight
        ])
    }

    private func configureInformation() {
        mediaTypeLabel.font = .systemFont(ofSize: 11, weight: .heavy)
        mediaTypeLabel.textColor = AppTheme.Color.primary
        mediaTypeLabel.backgroundColor = AppTheme.Color.primary.withAlphaComponent(0.11)
        mediaTypeLabel.contentInsets = UIEdgeInsets(top: 7, left: 11, bottom: 7, right: 11)
        mediaTypeLabel.layer.cornerRadius = 11
        mediaTypeLabel.layer.cornerCurve = .continuous
        mediaTypeLabel.clipsToBounds = true

        titleLabel.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(
            for: .systemFont(ofSize: 34, weight: .bold)
        )
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true

        originalTitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        originalTitleLabel.textColor = AppTheme.Color.textSecondary
        originalTitleLabel.numberOfLines = 0
        originalTitleLabel.adjustsFontForContentSizeCategory = true

        [yearLabel, ratingLabel].forEach { label in
            label.font = .systemFont(ofSize: 13, weight: .semibold)
            label.textColor = AppTheme.Color.textPrimary
            label.backgroundColor = AppTheme.Color.surface
            label.layer.borderWidth = 1
            label.layer.borderColor = AppTheme.Color.border.cgColor
            label.layer.cornerRadius = 13
            label.layer.cornerCurve = .continuous
            label.clipsToBounds = true
            label.contentInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        }
        ratingLabel.textColor = AppTheme.Color.secondaryAccent

        metadataStack.axis = .horizontal
        metadataStack.spacing = 8
        metadataStack.addArrangedSubview(yearLabel)
        metadataStack.addArrangedSubview(ratingLabel)

        informationStack.axis = .vertical
        informationStack.alignment = .leading
        informationStack.spacing = 10
        [mediaTypeLabel, titleLabel, originalTitleLabel, metadataStack].forEach {
            informationStack.addArrangedSubview($0)
        }
        informationStack.setCustomSpacing(14, after: mediaTypeLabel)
        informationStack.setCustomSpacing(16, after: originalTitleLabel)
    }

    private func updateFallbackColors() {
        let traits = traitCollection
        fallbackGradient.colors = [
            AppTheme.Color.primary.resolvedColor(with: traits).withAlphaComponent(0.58).cgColor,
            AppTheme.Color.accent.resolvedColor(with: traits).withAlphaComponent(0.38).cgColor,
            AppTheme.Color.surface.resolvedColor(with: traits).cgColor
        ]
    }

    private func setPosterImage(_ image: UIImage?) {
        posterImageView.image = image
        topFadeView.isHidden = image == nil || !artworkStartsBelowSafeArea
        fallbackGradient.isHidden = image != nil
        posterImageHeightConstraint?.isActive = false
        posterHeightConstraint?.isActive = false
        fadeBottomConstraint?.isActive = false
        fadeHeightConstraint?.isActive = false

        if let image, image.size.width > 0 {
            let aspectRatio = image.size.height / image.size.width
            posterImageHeightConstraint = posterImageView.heightAnchor.constraint(
                equalTo: posterImageView.widthAnchor,
                multiplier: aspectRatio
            )
            if aspectRatio < 1.1 {
                posterHeightConstraint = posterView.heightAnchor.constraint(
                    equalTo: posterImageView.heightAnchor,
                    constant: 48 + (posterImageTopConstraint?.constant ?? 0)
                )
                fadeBottomConstraint = posterFadeView.bottomAnchor.constraint(
                    equalTo: posterImageView.bottomAnchor
                )
                fadeHeightConstraint = posterFadeView.heightAnchor.constraint(
                    equalTo: posterImageView.heightAnchor,
                    multiplier: artworkStartsBelowSafeArea
                        ? ArtworkMetrics.gameBottomFadeRatio
                        : ArtworkMetrics.standardLandscapeBottomFadeRatio
                )
            } else {
                configurePortraitLayout()
            }
        } else {
            posterImageHeightConstraint = posterImageView.heightAnchor.constraint(
                equalTo: posterView.heightAnchor
            )
            configurePortraitLayout()
        }
        posterHeightConstraint?.priority = .defaultHigh
        [posterImageHeightConstraint, posterHeightConstraint, fadeBottomConstraint, fadeHeightConstraint]
            .compactMap { $0 }
            .forEach { $0.isActive = true }
    }

    private func configurePortraitLayout() {
        posterHeightConstraint = posterView.heightAnchor.constraint(
            equalTo: posterView.widthAnchor,
            multiplier: 1.4
        )
        fadeBottomConstraint = posterFadeView.bottomAnchor.constraint(equalTo: posterView.bottomAnchor)
        fadeHeightConstraint = posterFadeView.heightAnchor.constraint(
            equalTo: posterView.heightAnchor,
            multiplier: artworkStartsBelowSafeArea
                ? ArtworkMetrics.gameBottomFadeRatio
                : ArtworkMetrics.standardBottomFadeRatio
        )
    }

    private func updateArtworkTopInset() {
        let inset = artworkStartsBelowSafeArea
            ? safeAreaTopInset + ArtworkMetrics.gameTopInset
            : 0
        guard posterImageTopConstraint?.constant != inset else { return }
        posterImageTopConstraint?.constant = inset
        if let image = posterImageView.image {
            setPosterImage(image)
        }
    }
}
