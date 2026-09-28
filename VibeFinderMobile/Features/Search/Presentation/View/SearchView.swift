import UIKit

final class SearchView: UIView {
    var onSuggestionSelected: ((SearchSuggestionDisplayModel) -> Void)?
    var onSuggestionDeleted: ((SearchSuggestionDisplayModel) -> Void)?
    var onCustomSuggestionSubmitted: ((String) -> Void)?
    var onMoreSuggestionsSelected: (() -> Void)?
    var onHistorySeeAllSelected: (() -> Void)?
    var onHistorySelected: ((SearchHistoryEntryDisplayModel) -> Void)?

    var promptTextView: UITextView {
        promptCardView.textView
    }

    var submitButton: UIButton {
        promptCardView.submitButton
    }

    private let state: SearchViewModel.State
    private let headerView: SearchHeaderView
    private let promptCardView = SearchPromptCardView()
    private lazy var suggestionsView = SearchSuggestionsView(
        suggestions: state.visibleSuggestions,
        canShowMoreSuggestions: state.canShowMoreSuggestions
    )
    private lazy var recentVibesView = RecentVibesView(history: state.recentHistory)
    private let statusView = SearchStatusView()
    private let loadingView = SearchLoadingView()
    private var pendingHistoryInsertionID: Int?

    init(state: SearchViewModel.State) {
        self.state = state
        headerView = SearchHeaderView(username: state.username)
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = AppTheme.Color.background
        accessibilityIdentifier = "search.screen"
        suggestionsView.onSuggestionSelected = { [weak self] suggestion in
            self?.onSuggestionSelected?(suggestion)
        }
        suggestionsView.onSuggestionDeleted = { [weak self] suggestion in
            self?.onSuggestionDeleted?(suggestion)
        }
        suggestionsView.onCustomSuggestionSubmitted = { [weak self] suggestion in
            self?.onCustomSuggestionSubmitted?(suggestion)
        }
        suggestionsView.onMoreSuggestionsSelected = { [weak self] in
            self?.onMoreSuggestionsSelected?()
        }
        recentVibesView.onSeeAllSelected = { [weak self] in
            self?.onHistorySeeAllSelected?()
        }
        recentVibesView.onHistorySelected = { [weak self] history in
            self?.onHistorySelected?(history)
        }
        let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        dismissTapGesture.cancelsTouchesInView = false
        dismissTapGesture.delegate = self
        addGestureRecognizer(dismissTapGesture)

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = makeTitleLabel()
        let contentStack = UIStackView(arrangedSubviews: [
            headerView,
            titleLabel,
            promptCardView,
            statusView,
            suggestionsView,
            recentVibesView
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.setCustomSpacing(10, after: titleLabel)
        contentStack.setCustomSpacing(12, after: promptCardView)
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

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 12),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -12),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -28),

            loadingView.topAnchor.constraint(equalTo: topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: bottomAnchor),
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
        headerView.render(avatar: state.avatar, initials: state.avatarInitials)
        promptCardView.setLoading(state.isLoading)
        statusView.setMessage(state.errorMessage)
        suggestionsView.render(
            suggestions: state.visibleSuggestions,
            canShowMoreSuggestions: state.canShowMoreSuggestions
        )
        pendingHistoryInsertionID = state.recentHistoryInsertionID
        recentVibesView.render(
            state.recentHistory,
            pendingInsertionID: state.recentHistoryInsertionID
        )
        loadingView.setVisible(state.isLoading)
    }

    func animatePendingHistoryInsertion(
        after delay: TimeInterval,
        completion: @escaping () -> Void
    ) {
        guard pendingHistoryInsertionID != nil else {
            completion()
            return
        }

        recentVibesView.animatePendingInsertion(after: delay) { [weak self] in
            self?.pendingHistoryInsertionID = nil
            completion()
        }
    }

    func setPromptText(_ text: String) {
        setPromptText(text, shouldBecomeFirstResponder: true)
    }

    func setPromptText(_ text: String, shouldBecomeFirstResponder: Bool) {
        promptCardView.setQuery(text, animated: true)
        if shouldBecomeFirstResponder {
            promptTextView.becomeFirstResponder()
        }
    }

    @objc private func backgroundTapped() {
        endEditing(true)
        suggestionsView.cancelCustomSuggestionInput()
    }
}

extension SearchView: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        guard let touchedView = touch.view else {
            return true
        }

        return !touchedView.isDescendant(of: suggestionsView)
    }
}
