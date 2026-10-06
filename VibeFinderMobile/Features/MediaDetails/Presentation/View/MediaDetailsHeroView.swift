import UIKit

final class MediaDetailsHeroView: UIView {
    private let imageLoader: RemoteImageLoading
    private var imageTask: URLSessionDataTask?
    private var representedURL: URL?

    private let posterView = UIView()
    private let posterImageView = UIImageView()
    private let fallbackIconView = UIImageView()
    private let gradientLayer = CAGradientLayer()
    private let mediaTypeLabel = UILabel()
    private let titleLabel = UILabel()
    private let originalTitleLabel = UILabel()
    private let yearLabel = UILabel()
    private let ratingLabel = UILabel()
    private let metadataStack = UIStackView()

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
        gradientLayer.frame = posterView.bounds
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
        fallbackIconView.image = UIImage(systemName: model.fallbackSymbol)
        fallbackIconView.isHidden = false
        imageTask = imageLoader.loadImage(from: model.imageURL) { [weak self] image in
            guard let self, self.representedURL == model.imageURL else { return }
            self.posterImageView.image = image
            self.fallbackIconView.isHidden = image != nil
        }
    }

    private func configure() {
        posterView.backgroundColor = AppTheme.Color.surface
        posterView.layer.cornerRadius = 24
        posterView.layer.cornerCurve = .continuous
        posterView.layer.masksToBounds = true
        posterView.layer.borderWidth = 1
        posterView.layer.borderColor = AppTheme.Color.border.cgColor

        gradientLayer.colors = [
            AppTheme.Color.primary.withAlphaComponent(0.46).cgColor,
            AppTheme.Color.surface.cgColor,
            AppTheme.Color.accent.withAlphaComponent(0.32).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        posterView.layer.addSublayer(gradientLayer)

        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        fallbackIconView.tintColor = AppTheme.Color.primary
        fallbackIconView.contentMode = .scaleAspectFit

        posterView.addSubview(posterImageView)
        posterView.addSubview(fallbackIconView)
        [posterImageView, fallbackIconView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        mediaTypeLabel.font = .systemFont(ofSize: 12, weight: .heavy)
        mediaTypeLabel.textColor = AppTheme.Color.secondaryAccent
        mediaTypeLabel.textAlignment = .center

        titleLabel.font = .systemFont(ofSize: 31, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true

        originalTitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        originalTitleLabel.textColor = AppTheme.Color.textSecondary
        originalTitleLabel.textAlignment = .center
        originalTitleLabel.numberOfLines = 0

        [yearLabel, ratingLabel].forEach { label in
            label.font = .systemFont(ofSize: 14, weight: .bold)
            label.textColor = AppTheme.Color.textPrimary
            label.textAlignment = .center
        }
        ratingLabel.textColor = AppTheme.Color.secondaryAccent
        metadataStack.axis = .horizontal
        metadataStack.alignment = .center
        metadataStack.spacing = 16
        metadataStack.addArrangedSubview(yearLabel)
        metadataStack.addArrangedSubview(ratingLabel)

        let stack = UIStackView(arrangedSubviews: [posterView, mediaTypeLabel, titleLabel, originalTitleLabel, metadataStack])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.setCustomSpacing(24, after: posterView)
        stack.setCustomSpacing(4, after: titleLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            posterView.widthAnchor.constraint(equalToConstant: 198),
            posterView.heightAnchor.constraint(equalToConstant: 288),
            posterImageView.topAnchor.constraint(equalTo: posterView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: posterView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: posterView.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: posterView.bottomAnchor),
            fallbackIconView.centerXAnchor.constraint(equalTo: posterView.centerXAnchor),
            fallbackIconView.centerYAnchor.constraint(equalTo: posterView.centerYAnchor),
            fallbackIconView.widthAnchor.constraint(equalToConstant: 76),
            fallbackIconView.heightAnchor.constraint(equalTo: fallbackIconView.widthAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.widthAnchor.constraint(equalTo: stack.widthAnchor),
            originalTitleLabel.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])
    }
}
