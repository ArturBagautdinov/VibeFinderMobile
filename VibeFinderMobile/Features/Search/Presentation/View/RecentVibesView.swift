import UIKit

final class RecentVibesView: UIView {
    var onSeeAllSelected: (() -> Void)?
    var onHistorySelected: ((SearchHistoryEntryDisplayModel) -> Void)?

    private let listStackView = UIStackView()
    private let emptyView = SearchHistoryEmptyView()
    private var rowViewsByID: [Int: SearchHistoryRowView] = [:]
    private var preparedInsertionID: Int?
    private var animatedInsertionIDs = Set<Int>()

    init(history: [SearchHistoryEntryDisplayModel]) {
        super.init(frame: .zero)
        configure()
        render(history)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        listStackView.axis = .vertical
        listStackView.spacing = 16

        emptyView.isHidden = true

        let stackView = UIStackView(arrangedSubviews: [
            makeHeader(),
            listStackView,
            emptyView
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func render(
        _ history: [SearchHistoryEntryDisplayModel],
        pendingInsertionID: Int? = nil
    ) {
        listStackView.arrangedSubviews.forEach { view in
            listStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        rowViewsByID.removeAll()
        preparedInsertionID = pendingInsertionID

        isHidden = false
        emptyView.isHidden = !history.isEmpty

        history.map { makeRow($0, pendingInsertionID: pendingInsertionID) }
            .forEach(listStackView.addArrangedSubview)
    }

    func animatePendingInsertion(
        after delay: TimeInterval,
        completion: @escaping () -> Void
    ) {
        guard
            let insertionID = preparedInsertionID,
            !animatedInsertionIDs.contains(insertionID),
            let row = rowViewsByID[insertionID]
        else {
            completion()
            return
        }

        animatedInsertionIDs.insert(insertionID)
        UIView.animate(
            withDuration: 0.55,
            delay: delay,
            usingSpringWithDamping: 0.78,
            initialSpringVelocity: 0.45,
            options: [.curveEaseOut, .allowUserInteraction]
        ) {
            row.alpha = 1
            row.transform = .identity
        } completion: { _ in
            completion()
        }
    }

    private func makeHeader() -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = L10n.Search.Recent.title
        titleLabel.font = .systemFont(ofSize: 24, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary

        let seeAllButton = UIButton(type: .system)
        seeAllButton.setTitle(L10n.Search.Recent.seeAll, for: .normal)
        seeAllButton.tintColor = AppTheme.Color.primary
        seeAllButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        seeAllButton.accessibilityIdentifier = "search.seeAllButton"
        seeAllButton.addAction(
            UIAction { [weak self] _ in
                self?.onSeeAllSelected?()
            },
            for: .touchUpInside
        )

        let stackView = UIStackView(arrangedSubviews: [titleLabel, seeAllButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }

    private func makeRow(
        _ history: SearchHistoryEntryDisplayModel,
        pendingInsertionID: Int?
    ) -> SearchHistoryRowView {
        let row = SearchHistoryRowView(history: history)
        rowViewsByID[history.id] = row
        if pendingInsertionID == history.id, !animatedInsertionIDs.contains(history.id) {
            row.alpha = 0
            row.transform = CGAffineTransform(translationX: 0, y: -14)
                .scaledBy(x: 0.96, y: 0.96)
        }
        row.onSelected = { [weak self] in
            self?.onHistorySelected?(history)
        }
        return row
    }
}
