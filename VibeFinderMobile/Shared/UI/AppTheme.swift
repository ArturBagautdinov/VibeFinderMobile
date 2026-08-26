import UIKit

enum AppTheme {
    enum Color {
        static let background = Asset.appBackground.color
        static let surface = Asset.appSurface.color
        static let primary = Asset.appPrimary.color
        static let accent = Asset.appAccent.color
        static let secondaryAccent = Asset.appSecondaryAccent.color
        static let textPrimary = Asset.appTextPrimary.color
        static let textSecondary = Asset.appTextSecondary.color
        static let border = Asset.appBorder.color
    }

    static func makeLogoImageView(height: CGFloat = 72) -> UIImageView {
        let imageView = UIImageView(image: Asset.appLogo.image.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = Color.primary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
        return imageView
    }
}
