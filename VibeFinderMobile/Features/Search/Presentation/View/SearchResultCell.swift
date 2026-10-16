import UIKit

final class SearchResultCell: UICollectionViewCell {
    private let imageContainer = UIView()
    private let imageView = UIImageView()
    private let gradientOverlayView = UIView()
    private let fallbackIconView = UIImageView(image: UIImage(systemName: "sparkles"))
    private let mediaTypeLabel = PaddedLabel()
    private let matchLabel = PaddedLabel()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private let gradientLayer = CAGradientLayer()
    private var imageTask: URLSessionDataTask?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        imageView.image = nil
        fallbackIconView.isHidden = false
        contentView.layer.shadowOpacity = 0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientOverlayView.bounds
    }

    func configure(
        with displayModel: SearchResultCellDisplayModel,
        imageLoader: RemoteImageLoading
    ) {
        mediaTypeLabel.text = displayModel.mediaType
        accessibilityIdentifier = "search.results.media.\(displayModel.mediaId)"
        matchLabel.text = displayModel.matchText
        titleLabel.text = displayModel.title
        metaLabel.text = displayModel.meta

        configureHighlight(displayModel.isTopMatch)
        loadImage(from: displayModel.imageURL, imageLoader: imageLoader)
    }

    private func configure() {
        contentView.backgroundColor = .clear

        configureImageContainer()
        configureLabels()

        let stackView = UIStackView(arrangedSubviews: [imageContainer, titleLabel, metaLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageContainer.heightAnchor.constraint(equalTo: imageContainer.widthAnchor, multiplier: 1.5)
        ])
    }

    private func configureImageContainer() {
        imageContainer.backgroundColor = AppTheme.Color.surface
        imageContainer.layer.cornerRadius = 18
        imageContainer.layer.cornerCurve = .continuous
        imageContainer.layer.masksToBounds = true
        imageContainer.layer.borderWidth = 1
        imageContainer.layer.borderColor = AppTheme.Color.border.cgColor

        gradientLayer.colors = [
            UIColor.clear.cgColor,
            AppTheme.Color.background.withAlphaComponent(0.82).cgColor
        ]
        gradientLayer.locations = [0.42, 1]
        gradientOverlayView.isUserInteractionEnabled = false
        gradientOverlayView.layer.addSublayer(gradientLayer)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        fallbackIconView.tintColor = AppTheme.Color.primary
        fallbackIconView.contentMode = .scaleAspectFit

        configureBadge(mediaTypeLabel)
        configureBadge(matchLabel)

        [imageView, gradientOverlayView, fallbackIconView, mediaTypeLabel, matchLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            imageContainer.addSubview($0)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),

            gradientOverlayView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            gradientOverlayView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            gradientOverlayView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            gradientOverlayView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),

            fallbackIconView.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            fallbackIconView.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor),
            fallbackIconView.widthAnchor.constraint(equalTo: imageContainer.widthAnchor, multiplier: 0.28),
            fallbackIconView.heightAnchor.constraint(equalTo: fallbackIconView.widthAnchor),

            mediaTypeLabel.topAnchor.constraint(equalTo: imageContainer.topAnchor, constant: 10),
            mediaTypeLabel.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor, constant: 10),

            matchLabel.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor, constant: 10),
            matchLabel.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: -10)
        ])
    }

    private func configureLabels() {
        titleLabel.font = .systemFont(ofSize: 18, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontForContentSizeCategory = true

        metaLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        metaLabel.textColor = AppTheme.Color.textSecondary
        metaLabel.numberOfLines = 1
        metaLabel.adjustsFontForContentSizeCategory = true
    }

    private func configureBadge(_ label: PaddedLabel) {
        label.font = .systemFont(ofSize: 13, weight: .black)
        label.textColor = AppTheme.Color.textPrimary
        label.backgroundColor = AppTheme.Color.background.withAlphaComponent(0.72)
        label.layer.cornerRadius = 12
        label.layer.cornerCurve = .continuous
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.contentInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
    }

    private func configureHighlight(_ isTopMatch: Bool) {
        imageContainer.layer.borderColor = isTopMatch
            ? AppTheme.Color.primary.cgColor
            : AppTheme.Color.border.cgColor
        imageContainer.layer.borderWidth = isTopMatch ? 2 : 1

        matchLabel.textColor = isTopMatch ? AppTheme.Color.secondaryAccent : AppTheme.Color.textPrimary
        matchLabel.backgroundColor = isTopMatch
            ? AppTheme.Color.primary.withAlphaComponent(0.24)
            : AppTheme.Color.background.withAlphaComponent(0.72)

        contentView.layer.shadowColor = AppTheme.Color.primary.cgColor
        contentView.layer.shadowOpacity = isTopMatch ? 0.42 : 0
        contentView.layer.shadowRadius = isTopMatch ? 20 : 0
        contentView.layer.shadowOffset = CGSize(width: 0, height: 12)
    }

    private func loadImage(from url: URL?, imageLoader: RemoteImageLoading) {
        imageTask = imageLoader.loadImage(from: url) { [weak self] image in
            self?.imageView.image = image
            self?.fallbackIconView.isHidden = image != nil
        }
    }
}
