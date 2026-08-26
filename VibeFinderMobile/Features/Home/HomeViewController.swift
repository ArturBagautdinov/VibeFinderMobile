import UIKit

final class HomeViewController: UIViewController {
    private let username: String

    init(username: String) {
        self.username = username
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    private func configureView() {
        title = L10n.Home.title
        view.backgroundColor = AppTheme.Color.background
        view.accessibilityIdentifier = "home.screen"
        navigationItem.hidesBackButton = true

        let logoImageView = AppTheme.makeLogoImageView(height: 84)
        logoImageView.accessibilityIdentifier = "home.logo.image"

        let label = UILabel()
        label.text = L10n.Home.welcome(username)
        label.accessibilityIdentifier = "home.welcomeLabel"
        label.font = .preferredFont(forTextStyle: .title2)
        label.textColor = AppTheme.Color.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0

        let stackView = UIStackView(arrangedSubviews: [logoImageView, label])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
}
