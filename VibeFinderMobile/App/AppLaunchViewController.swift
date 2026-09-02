import UIKit

final class AppLaunchViewController: UIViewController {
    override func loadView() {
        view = AppLaunchView()
    }
}

private final class AppLaunchView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = AppTheme.Color.background

        let vibeLabel = makeBrandLabel(text: "Vibe", color: AppTheme.Color.primary)
        let finderLabel = makeBrandLabel(text: "Finder", color: AppTheme.Color.secondaryAccent)

        let brandStackView = UIStackView(arrangedSubviews: [vibeLabel, finderLabel])
        brandStackView.axis = .horizontal
        brandStackView.alignment = .center
        brandStackView.spacing = 8
        brandStackView.translatesAutoresizingMaskIntoConstraints = false

        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = AppTheme.Color.primary
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [brandStackView, activityIndicator])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func makeBrandLabel(text: String, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 38, weight: .black)
        label.textColor = color
        label.layer.shadowColor = color.cgColor
        label.layer.shadowOpacity = 0.34
        label.layer.shadowRadius = 14
        label.layer.shadowOffset = .zero
        return label
    }
}
