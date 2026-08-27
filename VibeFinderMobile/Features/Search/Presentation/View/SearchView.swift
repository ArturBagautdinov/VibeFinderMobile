import UIKit

final class SearchView: UIView {
    var promptTextView: UITextView {
        promptCardView.textView
    }

    var submitButton: UIButton {
        promptCardView.submitButton
    }

    private let state: SearchViewModel.State
    private let promptCardView = SearchPromptCardView()
    private let statusView = SearchStatusView()
    private let resultsView = SearchResultsView()

    init(state: SearchViewModel.State) {
        self.state = state
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = AppTheme.Color.background
        accessibilityIdentifier = "search.screen"

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = makeTitleLabel()
        let contentStack = UIStackView(arrangedSubviews: [
            SearchHeaderView(username: state.username),
            titleLabel,
            promptCardView,
            statusView,
            resultsView,
            SearchSuggestionsView(suggestions: state.suggestions),
            RecentVibesView(recentVibes: state.recentVibes)
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.setCustomSpacing(10, after: titleLabel)
        contentStack.setCustomSpacing(12, after: promptCardView)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(contentStack)
        addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 12),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -12),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -28),
        ])

        render(state)
    }

    private func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.text = L10n.Search.title
        label.accessibilityIdentifier = "search.titleLabel"
        label.font = .systemFont(ofSize: 34, weight: .black)
        label.textColor = AppTheme.Color.textPrimary
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }

    func render(_ state: SearchViewModel.State) {
        promptCardView.setLoading(state.isLoading)
        statusView.setMessage(state.errorMessage)
        resultsView.render(page: state.result)
    }
}
