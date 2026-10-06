import UIKit

final class MediaDetailsView: UIView {
    let backButton = UIButton(type: .system)
    let retryButton = UIButton(type: .system)

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let heroView: MediaDetailsHeroView
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let loadingStack = UIStackView()
    private let errorStack = UIStackView()
    private let errorMessageLabel = UILabel()

    init(imageLoader: RemoteImageLoading) {
        heroView = MediaDetailsHeroView(imageLoader: imageLoader)
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showLoading() {
        scrollView.isHidden = true
        errorStack.isHidden = true
        loadingStack.isHidden = false
        loadingIndicator.startAnimating()
    }

    func showError(_ message: String) {
        scrollView.isHidden = true
        loadingStack.isHidden = true
        loadingIndicator.stopAnimating()
        errorMessageLabel.text = message
        errorStack.isHidden = false
    }

    func showContent(_ model: MediaDetailsDisplayModel) {
        loadingStack.isHidden = true
        loadingIndicator.stopAnimating()
        errorStack.isHidden = true

        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        heroView.configure(with: model)
        contentStack.addArrangedSubview(heroView)
        contentStack.setCustomSpacing(26, after: heroView)

        if !model.facts.isEmpty {
            contentStack.addArrangedSubview(MediaDetailsChipRowView(title: nil, items: model.facts))
        }
        if let explanation = model.explanation {
            contentStack.addArrangedSubview(MediaDetailsTextSectionView(
                title: L10n.Media.Details.whyFits,
                body: explanation,
                style: .highlight
            ))
        }
        if let warning = model.warning {
            contentStack.addArrangedSubview(MediaDetailsTextSectionView(
                title: L10n.Media.Details.warning,
                body: warning,
                style: .warning
            ))
        }
        if let description = model.description {
            contentStack.addArrangedSubview(MediaDetailsTextSectionView(
                title: L10n.Media.Details.about,
                body: description
            ))
        }
        for group in model.tagGroups {
            contentStack.addArrangedSubview(MediaDetailsChipRowView(
                title: group.title,
                items: group.tags
            ))
        }

        scrollView.setContentOffset(.zero, animated: false)
        scrollView.isHidden = false
    }

    private func configure() {
        backgroundColor = AppTheme.Color.background
        accessibilityIdentifier = "media.details.screen"
        configureBackButton()
        configureScrollView()
        configureLoadingState()
        configureErrorState()

        [scrollView, loadingStack, errorStack, backButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 42),
            backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor),

            scrollView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            loadingStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingStack.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),

            errorStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorStack.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            errorStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            errorStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24),
            errorStack.widthAnchor.constraint(lessThanOrEqualToConstant: 330)
        ])

        scrollView.isHidden = true
        loadingStack.isHidden = true
        errorStack.isHidden = true
    }

    private func configureBackButton() {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "chevron.left")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)
        configuration.baseBackgroundColor = AppTheme.Color.surface
        configuration.baseForegroundColor = AppTheme.Color.primary
        configuration.cornerStyle = .capsule
        backButton.configuration = configuration
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = AppTheme.Color.border.cgColor
        backButton.accessibilityIdentifier = "media.details.backButton"
        backButton.accessibilityLabel = L10n.Media.Details.back
    }

    private func configureScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 10),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -36),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }

    private func configureLoadingState() {
        loadingIndicator.color = AppTheme.Color.primary
        let label = UILabel()
        label.text = L10n.Media.Details.loading
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = AppTheme.Color.textSecondary
        loadingStack.axis = .vertical
        loadingStack.alignment = .center
        loadingStack.spacing = 14
        loadingStack.addArrangedSubview(loadingIndicator)
        loadingStack.addArrangedSubview(label)
    }

    private func configureErrorState() {
        let icon = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
        icon.tintColor = AppTheme.Color.secondaryAccent
        icon.contentMode = .scaleAspectFit
        icon.heightAnchor.constraint(equalToConstant: 42).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = L10n.Media.Details.errorTitle
        titleLabel.font = .systemFont(ofSize: 21, weight: .bold)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.textAlignment = .center

        errorMessageLabel.font = .systemFont(ofSize: 15)
        errorMessageLabel.textColor = AppTheme.Color.textSecondary
        errorMessageLabel.textAlignment = .center
        errorMessageLabel.numberOfLines = 0

        var retryConfiguration = UIButton.Configuration.filled()
        retryConfiguration.title = L10n.Common.retry
        retryConfiguration.baseBackgroundColor = AppTheme.Color.primary
        retryConfiguration.baseForegroundColor = AppTheme.Color.background
        retryConfiguration.cornerStyle = .capsule
        retryButton.configuration = retryConfiguration
        retryButton.accessibilityIdentifier = "media.details.retryButton"

        errorStack.axis = .vertical
        errorStack.alignment = .fill
        errorStack.spacing = 14
        [icon, titleLabel, errorMessageLabel, retryButton].forEach(errorStack.addArrangedSubview)
        errorStack.setCustomSpacing(24, after: errorMessageLabel)
    }
}
