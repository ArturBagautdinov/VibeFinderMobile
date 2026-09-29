//
//  ProfileChipLabel.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 16.09.2026.
//

import Foundation
import UIKit

final class ProfileChipLabel: UILabel {
    var insets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: max(36, size.height + insets.top + insets.bottom)
        )
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
