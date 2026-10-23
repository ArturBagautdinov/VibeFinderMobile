import UIKit

final class FavoritesItemCell: UICollectionViewCell {
    private let artworkView = UIView()
    private let imageView = UIImageView()
    private let fallbackIconView = UIImageView()
    private let typeLabel = UILabel()
    private let titleLabel = UILabel()
    private let yearLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var imageTask: URLSessionDataTask?
    private var representedImageURL: URL?

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
        representedImageURL = nil
        imageView.image = nil
        fallbackIconView.isHidden = false
    }

    func configure(with item: FavoriteItemDisplayModel, imageLoader: RemoteImageLoading) {
        accessibilityIdentifier = "favorites.item.\(item.mediaId)"
        accessibilityLabel = [item.title, item.mediaType, item.releaseYear]
            .compactMap { $0 }
            .joined(separator: ", ")
        typeLabel.text = item.mediaType.uppercased()
        titleLabel.text = item.title
        yearLabel.text = item.releaseYear
        yearLabel.isHidden = item.releaseYear == nil
        descriptionLabel.text = item.description
        descriptionLabel.isHidden = item.description?.isEmpty != false
        fallbackIconView.image = UIImage(systemName: item.fallbackSymbol)
        loadImage(from: item.imageURL, imageLoader: imageLoader)
    }

    private func configure() {
        isAccessibilityElement = true
        accessibilityTraits = .button
        contentView.backgroundColor = AppTheme.Color.surface.withAlphaComponent(0.82)
        contentView.layer.cornerRadius = 22
        contentView.layer.cornerCurve = .continuous
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = AppTheme.Color.border.cgColor
        contentView.layer.masksToBounds = true

        configureArtwork()
        configureLabels()

        let metadataStack = UIStackView(arrangedSubviews: [typeLabel, yearLabel])
        metadataStack.axis = .horizontal
        metadataStack.alignment = .center
        metadataStack.spacing = 8

        let textStack = UIStackView(arrangedSubviews: [metadataStack, titleLabel, descriptionLabel])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 8

        let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronView.tintColor = AppTheme.Color.primary.withAlphaComponent(0.8)
        chevronView.contentMode = .scaleAspectFit
        chevronView.setContentHuggingPriority(.required, for: .horizontal)
        chevronView.widthAnchor.constraint(equalToConstant: 12).isActive = true

        let row = UIStackView(arrangedSubviews: [artworkView, textStack, chevronView])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)

        NSLayoutConstraint.activate([
            artworkView.widthAnchor.constraint(equalToConstant: 104),
            artworkView.heightAnchor.constraint(equalToConstant: 138),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    private func configureArtwork() {
        artworkView.backgroundColor = AppTheme.Color.background
        artworkView.layer.cornerRadius = 15
        artworkView.layer.cornerCurve = .continuous
        artworkView.layer.masksToBounds = true

        imageView.contentMode = .scaleAspectFit
        fallbackIconView.tintColor = AppTheme.Color.primary
        fallbackIconView.contentMode = .scaleAspectFit

        [imageView, fallbackIconView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            artworkView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: artworkView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: artworkView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: artworkView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: artworkView.bottomAnchor),
            fallbackIconView.centerXAnchor.constraint(equalTo: artworkView.centerXAnchor),
            fallbackIconView.centerYAnchor.constraint(equalTo: artworkView.centerYAnchor),
            fallbackIconView.widthAnchor.constraint(equalToConstant: 32),
            fallbackIconView.heightAnchor.constraint(equalTo: fallbackIconView.widthAnchor)
        ])
    }

    private func configureLabels() {
        typeLabel.font = .systemFont(ofSize: 11, weight: .heavy)
        typeLabel.textColor = AppTheme.Color.primary
        typeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontForContentSizeCategory = true

        yearLabel.font = .preferredFont(forTextStyle: .caption1)
        yearLabel.textColor = AppTheme.Color.textSecondary
        yearLabel.adjustsFontForContentSizeCategory = true

        descriptionLabel.font = .preferredFont(forTextStyle: .subheadline)
        descriptionLabel.textColor = AppTheme.Color.textSecondary
        descriptionLabel.numberOfLines = 3
        descriptionLabel.adjustsFontForContentSizeCategory = true
    }

    private func loadImage(from url: URL?, imageLoader: RemoteImageLoading) {
        imageTask?.cancel()
        imageTask = nil
        imageView.image = nil
        fallbackIconView.isHidden = false
        representedImageURL = url

        imageTask = imageLoader.loadImage(from: url) { [weak self] image in
            guard let self, self.representedImageURL == url else { return }
            self.imageView.image = image
            self.fallbackIconView.isHidden = image != nil
        }
    }
}
