import UIKit

final class SearchHistoryRowCell: UICollectionViewCell {
    private let rowView = SearchHistoryRowView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        rowView.onSelected = nil
    }

    func configure(
        with history: SearchHistoryEntryDisplayModel,
        onSelected: @escaping () -> Void
    ) {
        rowView.configure(with: history)
        rowView.onSelected = onSelected
    }

    private func configure() {
        backgroundConfiguration = .clear()
        contentView.backgroundColor = .clear
        rowView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rowView)

        NSLayoutConstraint.activate([
            rowView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            rowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7)
        ])
    }
}
