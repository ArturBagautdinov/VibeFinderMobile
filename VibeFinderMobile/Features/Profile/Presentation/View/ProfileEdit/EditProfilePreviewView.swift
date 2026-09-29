import UIKit

final class EditProfilePreviewView: UIView {
    private let avatarView = ProfileAvatarView()
    private let nameLabel = UILabel()
    private let detailLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: 72),
            avatarView.heightAnchor.constraint(equalTo: avatarView.widthAnchor)
        ])
        nameLabel.font = .preferredFont(forTextStyle: .headline)
        nameLabel.textColor = AppTheme.Color.textPrimary
        detailLabel.font = .preferredFont(forTextStyle: .subheadline)
        detailLabel.textColor = AppTheme.Color.textSecondary
        detailLabel.numberOfLines = 2
        let labels = UIStackView(arrangedSubviews: [nameLabel, detailLabel])
        labels.axis = .vertical
        labels.spacing = 3
        let row = UIStackView(arrangedSubviews: [avatarView, labels])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: topAnchor),
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func render(_ state: EditProfileViewModel.State) {
        avatarView.render(avatar: state.draft.avatar, initials: state.initials)
        let name = [state.draft.firstName, state.draft.lastName]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        nameLabel.text = name.isEmpty ? state.original.username : name
        detailLabel.text = "@\(state.original.username) · \(state.original.email)"
    }
}
