import UIKit

final class FloatingPromptCloudView: UIView {
    private enum Layout {
        static let chipHeight: CGFloat = 38
    }

    private let prompts: [Prompt]
    private var chips: [UILabel] = []

    init(prompts: [Prompt]) {
        self.prompts = prompts
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutChips()
    }

    func startFloating() {
        chips.enumerated().forEach { index, chip in
            let animation = CABasicAnimation(keyPath: "transform.translation.y")
            animation.fromValue = -5 - CGFloat(index % 2)
            animation.toValue = 7 + CGFloat(index % 3)
            animation.duration = 2.4 + CFTimeInterval(index) * 0.18
            animation.autoreverses = true
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            chip.layer.add(animation, forKey: "floating.prompt.\(index)")
        }
    }

    private func configure() {
        clipsToBounds = false
        isUserInteractionEnabled = false
        prompts.forEach { prompt in
            let chip = makeChip(prompt)
            chips.append(chip)
            addSubview(chip)
        }
    }

    private func makeChip(_ prompt: Prompt) -> UILabel {
        let label = UILabel()
        label.text = prompt.title
        label.font = .preferredFont(forTextStyle: .subheadline).bold()
        label.textAlignment = .center
        label.textColor = prompt.color
        label.backgroundColor = AppTheme.Color.surface.withAlphaComponent(0.58)
        label.layer.cornerRadius = Layout.chipHeight / 2
        label.layer.cornerCurve = .continuous
        label.layer.borderWidth = 1.2
        label.layer.borderColor = prompt.color.withAlphaComponent(0.45).cgColor
        label.layer.shadowColor = prompt.color.cgColor
        label.layer.shadowOpacity = 0.16
        label.layer.shadowRadius = 10
        label.layer.shadowOffset = CGSize(width: 0, height: 6)
        label.clipsToBounds = false
        return label
    }

    private func layoutChips() {
        guard bounds.width > 0 else {
            return
        }

        let placements = chipPlacements(for: bounds.size)
        zip(chips, placements).forEach { chip, placement in
            let fittingSize = chip.sizeThatFits(CGSize(width: bounds.width - 48, height: Layout.chipHeight))
            let width = min(fittingSize.width + 32, bounds.width * 0.48)
            let x = placement.xAnchor == .leading
                ? placement.xOffset
                : bounds.width - width - placement.xOffset
            chip.frame = CGRect(
                x: x,
                y: placement.y,
                width: width,
                height: Layout.chipHeight
            )
            chip.transform = CGAffineTransform(rotationAngle: placement.rotation)
        }
    }

    private func chipPlacements(for size: CGSize) -> [ChipPlacement] {
        [
            ChipPlacement(xAnchor: .leading, xOffset: -14, y: size.height * 0.05, rotation: -0.04),
            ChipPlacement(xAnchor: .trailing, xOffset: 8, y: size.height * 0.14, rotation: 0.05),
            ChipPlacement(xAnchor: .leading, xOffset: -6, y: size.height * 0.29, rotation: 0.025),
            ChipPlacement(xAnchor: .trailing, xOffset: 0, y: size.height * 0.35, rotation: -0.045),
            ChipPlacement(xAnchor: .leading, xOffset: 10, y: size.height * 0.52, rotation: -0.02),
            ChipPlacement(xAnchor: .trailing, xOffset: 12, y: size.height * 0.59, rotation: 0.04)
        ]
    }
}

extension FloatingPromptCloudView {
    struct Prompt {
        let title: String
        let color: UIColor
    }
}

private struct ChipPlacement {
    enum XAnchor {
        case leading
        case trailing
    }

    let xAnchor: XAnchor
    let xOffset: CGFloat
    let y: CGFloat
    let rotation: CGFloat
}

private extension UIFont {
    func bold() -> UIFont {
        addingTraits(.traitBold)
    }

    func addingTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
