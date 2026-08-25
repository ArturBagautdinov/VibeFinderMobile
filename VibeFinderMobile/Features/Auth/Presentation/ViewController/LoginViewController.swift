import UIKit

final class LoginViewController: UIViewController, AlertPresenting {
    private let viewModel: LoginViewModel
    private let authView = AuthFormView(mode: .login)
    private var pendingSuccessMessage: String?

    var onRegisterSelected: (() -> Void)?

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureActions()
        bindViewModel()
    }

    override func loadView() {
        view = authView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentPendingSuccessIfNeeded()
    }

    func showSuccess(_ message: String) {
        pendingSuccessMessage = message
        presentPendingSuccessIfNeeded()
    }

    private func presentPendingSuccessIfNeeded() {
        guard let message = pendingSuccessMessage, view.window != nil, presentedViewController == nil else {
            return
        }

        pendingSuccessMessage = nil
        showAlert(title: L10n.Auth.Register.successTitle, message: message)
    }

    private func configureActions() {
        navigationItem.title = nil
        navigationItem.hidesBackButton = true
        authView.submitButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        authView.switchButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.authView.setLoading(state.isLoading)
            self?.authView.setError(state.errorMessage)
        }
    }

    @objc private func loginTapped() {
        view.endEditing(true)
        viewModel.login(
            login: authView.identifierField.text ?? "",
            password: authView.passwordField.text ?? ""
        )
    }

    @objc private func registerTapped() {
        onRegisterSelected?()
    }
}
