import UIKit

final class AuthOnboardingViewController: UIViewController {
    var onStartSelected: (() -> Void)?
    var onSignInSelected: (() -> Void)?

    private let authView = AuthOnboardingView()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureActions()
    }

    override func loadView() {
        view = authView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authView.startFloatingPrompts()
    }

    private func configureActions() {
        authView.startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        authView.signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
    }

    @objc private func startTapped() {
        onStartSelected?()
    }

    @objc private func signInTapped() {
        onSignInSelected?()
    }
}

enum AuthPromptFactory {
    static func makePrompts() -> [FloatingPromptCloudView.Prompt] {
        [
            FloatingPromptCloudView.Prompt(title: L10n.Auth.Prompt.rainyNightMovie, color: AppTheme.Color.primary),
            FloatingPromptCloudView.Prompt(title: L10n.Auth.Prompt.cozyGame, color: AppTheme.Color.accent),
            FloatingPromptCloudView.Prompt(title: L10n.Auth.Prompt.darkDetectiveSeries, color: AppTheme.Color.textSecondary),
            FloatingPromptCloudView.Prompt(title: L10n.Auth.Prompt.emotionalScifi, color: AppTheme.Color.secondaryAccent),
            FloatingPromptCloudView.Prompt(title: L10n.Auth.Prompt.somethingWeird, color: AppTheme.Color.primary),
            FloatingPromptCloudView.Prompt(title: L10n.Auth.Prompt.slowSunday, color: AppTheme.Color.accent)
        ]
    }
}
