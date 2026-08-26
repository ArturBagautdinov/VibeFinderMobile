import UIKit

final class PrimaryButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        configuration = .filled()
        configuration?.cornerStyle = .capsule
        configuration?.baseBackgroundColor = AppTheme.Color.primary
        configuration?.baseForegroundColor = .white
        titleLabel?.font = .preferredFont(forTextStyle: .headline)
        heightAnchor.constraint(equalToConstant: 52).isActive = true
    }

    func setLoading(_ isLoading: Bool) {
        isEnabled = !isLoading
        configuration?.showsActivityIndicator = isLoading
        configuration?.baseBackgroundColor = isLoading ? AppTheme.Color.textSecondary : AppTheme.Color.primary
    }
}
