import UIKit

final class RegisterViewController: UIViewController {
    private let viewModel: RegisterViewModel
    private let authView = AuthFormView(mode: .register)

    var onLoginSelected: (() -> Void)?

    init(viewModel: RegisterViewModel) {
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

    private func configureActions() {
        navigationItem.title = nil
        navigationItem.hidesBackButton = true
        authView.submitButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        authView.switchButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.authView.setLoading(state.isLoading)
            self?.authView.setError(state.errorMessage)
        }
    }

    @objc private func registerTapped() {
        view.endEditing(true)
        viewModel.register(
            email: authView.emailField.text ?? "",
            username: authView.usernameField.text ?? "",
            firstName: authView.firstNameField.text ?? "",
            lastName: authView.lastNameField.text ?? "",
            password: authView.passwordField.text ?? "",
            confirmPassword: authView.confirmPasswordField.text ?? ""
        )
    }

    @objc private func loginTapped() {
        onLoginSelected?()
    }
}
