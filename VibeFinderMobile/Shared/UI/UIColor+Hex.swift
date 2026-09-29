import UIKit

extension UIColor {
    convenience init?(hex: String) {
        let value = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "#"))

        guard
            (value.count == 6 || value.count == 8),
            let number = UInt64(value, radix: 16)
        else {
            return nil
        }

        let hasAlpha = value.count == 8
        self.init(
            red: CGFloat((number >> (hasAlpha ? 24 : 16)) & 0xFF) / 255,
            green: CGFloat((number >> (hasAlpha ? 16 : 8)) & 0xFF) / 255,
            blue: CGFloat((number >> (hasAlpha ? 8 : 0)) & 0xFF) / 255,
            alpha: hasAlpha ? CGFloat(number & 0xFF) / 255 : 1
        )
    }
}
