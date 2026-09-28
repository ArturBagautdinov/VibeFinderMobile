import UIKit

final class EditProfileViewController: UIViewController {
    private let viewModel: EditProfileViewModel
    private lazy var editView = EditProfileView(
        symbols: viewModel.availableSymbols,
        colors: viewModel.availableColors
    )
    private var wasPopGestureEnabled = true

    var onClose: (() -> Void)?
    var onSaved: ((UserProfile) -> Void)?

    init(viewModel: EditProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() { view = editView }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        wasPopGestureEnabled = navigationController?.interactivePopGestureRecognizer?.isEnabled ?? true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = wasPopGestureEnabled
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        editView.render(viewModel.state)
        editView.onBack = { [weak self] in self?.closeRequested() }
        editView.onSave = { [weak self] in self?.viewModel.save() }
        editView.onNamesChanged = { [weak self] first, last in
            self?.viewModel.setNames(firstName: first, lastName: last)
        }
        editView.onStyleSelected = { [weak self] in self?.viewModel.selectStyle($0) }
        editView.onSymbolSelected = { [weak self] in self?.viewModel.selectSymbol($0) }
        editView.onColorSelected = { [weak self] in self?.viewModel.selectColor($0) }
        viewModel.onStateChange = { [weak self] in self?.editView.render($0) }
        viewModel.onSaved = { [weak self] in self?.onSaved?($0) }
    }

    private func closeRequested() {
        guard !viewModel.state.isSaving else { return }
        guard viewModel.state.isDirty else {
            onClose?()
            return
        }
        let alert = UIAlertController(
            title: L10n.Profile.Edit.discardTitle,
            message: L10n.Profile.Edit.discardMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.Profile.Edit.discardAction, style: .destructive) { [weak self] _ in
            self?.onClose?()
        })
        present(alert, animated: true)
    }
}
