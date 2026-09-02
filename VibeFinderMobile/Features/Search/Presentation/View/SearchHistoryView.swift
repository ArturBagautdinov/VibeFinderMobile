import UIKit

final class SearchHistoryView: UIView {
    let backButton = UIButton(type: .system)
    var onHistorySelected: ((SearchHistoryEntryDisplayModel) -> Void)?

    private let listContainerView = UIView()
    private let listStackView = UIStackView()
    private let statusView = SearchStatusView()
    private let loadingView = SearchLoadingView()
    private lazy var emptyView = makeEmptyView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = AppTheme.Color.background
        accessibilityIdentifier = "search.history.screen"
        configureListContainer()

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let contentStack = UIStackView(arrangedSubviews: [
            makeHeader(),
            statusView,
            listContainerView
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(contentStack)
        addSubview(scrollView)
        addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 18),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -28),

            loadingView.topAnchor.constraint(equalTo: topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func render(_ state: SearchHistoryViewModel.State) {
        listStackView.arrangedSubviews.forEach { view in
            listStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        state.history.map(makeRow).forEach(listStackView.addArrangedSubview)
        emptyView.isHidden = !state.isEmpty
        listStackView.isHidden = state.isEmpty
        statusView.setMessage(state.errorMessage)
        loadingView.setVisible(state.isLoading)
    }

    private func makeHeader() -> UIView {
        configureBackButton()

        let titleLabel = UILabel()
        titleLabel.text = L10n.Search.Recent.fullTitle
        titleLabel.font = .systemFont(ofSize: 34, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true

        let stackView = UIStackView(arrangedSubviews: [backButton, titleLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16

        return stackView
    }

    private func configureBackButton() {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "chevron.left")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)
        configuration.baseBackgroundColor = AppTheme.Color.surface
        configuration.baseForegroundColor = AppTheme.Color.primary
        configuration.cornerStyle = .capsule
        backButton.configuration = configuration
        backButton.accessibilityIdentifier = "search.history.backButton"
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = AppTheme.Color.border.cgColor
        backButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor).isActive = true
    }

    private func makeEmptyView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = AppTheme.Color.surface.withAlphaComponent(0.58)
        containerView.layer.cornerRadius = 26
        containerView.layer.cornerCurve = .continuous
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = AppTheme.Color.primary.withAlphaComponent(0.3).cgColor
        containerView.layer.shadowColor = AppTheme.Color.primary.cgColor
        containerView.layer.shadowOpacity = 0.14
        containerView.layer.shadowRadius = 22
        containerView.layer.shadowOffset = CGSize(width: 0, height: 12)

        let iconContainer = UIView()
        iconContainer.backgroundColor = AppTheme.Color.primary.withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = 24
        iconContainer.layer.cornerCurve = .continuous
        iconContainer.layer.borderWidth = 1
        iconContainer.layer.borderColor = AppTheme.Color.secondaryAccent.withAlphaComponent(0.34).cgColor
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: "sparkle.magnifyingglass"))
        iconView.tintColor = AppTheme.Color.primary
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = L10n.Search.Recent.emptyTitle
        titleLabel.font = .systemFont(ofSize: 24, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = L10n.Search.Recent.emptySubtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.textColor = AppTheme.Color.textSecondary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center

        iconContainer.addSubview(iconView)

        let stackView = UIStackView(arrangedSubviews: [iconContainer, titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(stackView)

        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 74),
            iconContainer.heightAnchor.constraint(equalTo: iconContainer.widthAnchor),
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),

            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 34),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -34)
        ])

        return containerView
    }

    private func configureListContainer() {
        listStackView.axis = .vertical
        listStackView.spacing = 14
        listStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.translatesAutoresizingMaskIntoConstraints = false

        listContainerView.addSubview(listStackView)
        listContainerView.addSubview(emptyView)

        NSLayoutConstraint.activate([
            listStackView.topAnchor.constraint(equalTo: listContainerView.topAnchor),
            listStackView.leadingAnchor.constraint(equalTo: listContainerView.leadingAnchor),
            listStackView.trailingAnchor.constraint(equalTo: listContainerView.trailingAnchor),
            listStackView.bottomAnchor.constraint(equalTo: listContainerView.bottomAnchor),

            emptyView.topAnchor.constraint(equalTo: listContainerView.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: listContainerView.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: listContainerView.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: listContainerView.bottomAnchor)
        ])
    }

    private func makeRow(_ history: SearchHistoryEntryDisplayModel) -> SearchHistoryRowView {
        let row = SearchHistoryRowView(history: history)
        row.onSelected = { [weak self] in
            self?.onHistorySelected?(history)
        }
        return row
    }
}
