import UIKit

protocol AlertPresenting where Self: UIViewController {
    func showAlert(title: String, message: String)
}

extension AlertPresenting {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: L10n.Common.ok, style: .default))
        present(alertController, animated: true)
    }
}
