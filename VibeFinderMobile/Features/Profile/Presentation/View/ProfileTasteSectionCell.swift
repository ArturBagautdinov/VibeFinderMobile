//
//  ProfileTasteSectionCell.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 15.09.2026.
//

import UIKit

final class ProfileTasteSectionCell: UICollectionViewCell {
    private let iconContainerView = UIView()
    private let iconView = UIImageView(image: UIImage(systemName: "sparkles"))
    private let titleLabel = UILabel()
    private let chipsStackView = UIStackView()
    private let chipsScrollView = UIScrollView()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        chipsStackView.arrangedSubviews.forEach { view in
            chipsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    func configure(with section: ProfileInfoSectionDisplayModel) {
        titleLabel.text = section.title
        section.items.forEach { item in
            chipsStackView.addArrangedSubview(makeChip(item))
        }
    }

    private func configure() {
        backgroundColor = AppTheme.Color.surface
        layer.cornerRadius = 22
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = AppTheme.Color.border.cgColor
        layer.shadowColor = AppTheme.Color.primary.cgColor
        layer.shadowOpacity = 0.14
        layer.shadowRadius = 16
        layer.shadowOffset = CGSize(width: 0, height: 8)

        configureIcon()
        configureLabels()
        configureChipsStack()

        let headerStack = UIStackView(arrangedSubviews: [iconContainerView, titleLabel])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 10

        let contentStack = UIStackView(arrangedSubviews: [headerStack, chipsScrollView])
        contentStack.axis = .vertical
        contentStack.spacing = 14
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            iconContainerView.widthAnchor.constraint(equalToConstant: 34),
            iconContainerView.heightAnchor.constraint(equalTo: iconContainerView.widthAnchor),
            
            chipsScrollView.heightAnchor.constraint(equalToConstant: 170),
            
            chipsStackView.topAnchor.constraint(equalTo: chipsScrollView.contentLayoutGuide.topAnchor),
            chipsStackView.leadingAnchor.constraint(equalTo: chipsScrollView.contentLayoutGuide.leadingAnchor),
            chipsStackView.trailingAnchor.constraint(equalTo: chipsScrollView.contentLayoutGuide.trailingAnchor),
            chipsStackView.bottomAnchor.constraint(equalTo: chipsScrollView.contentLayoutGuide.bottomAnchor),
            chipsStackView.widthAnchor.constraint(equalTo: chipsScrollView.frameLayoutGuide.widthAnchor),

            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    private func configureIcon() {
        iconContainerView.backgroundColor = AppTheme.Color.primary.withAlphaComponent(0.16)
        iconContainerView.layer.cornerRadius = 17
        iconContainerView.layer.cornerCurve = .continuous
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false

        iconView.tintColor = AppTheme.Color.secondaryAccent
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        iconContainerView.addSubview(iconView)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor)
        ])
    }

    private func configureLabels() {
        titleLabel.font = .systemFont(ofSize: 18, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontForContentSizeCategory = true
    }

    private func configureChipsStack() {
        
        chipsScrollView.showsHorizontalScrollIndicator = false
        chipsScrollView.alwaysBounceVertical = true
        chipsScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        chipsStackView.axis = .vertical
        chipsStackView.alignment = .leading
        chipsStackView.spacing = 8
        chipsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        chipsScrollView.addSubview(chipsStackView)
    }
    
    private func makeChip(_ text: String) -> UILabel {
        let label = ProfileChipLabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = AppTheme.Color.textPrimary
        label.backgroundColor = AppTheme.Color.background.withAlphaComponent(0.55)
        label.layer.cornerCurve = .continuous
        label.layer.masksToBounds = true
        label.layer.borderWidth = 1
        label.layer.borderColor = AppTheme.Color.primary.withAlphaComponent(0.25).cgColor
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1

        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        label.widthAnchor.constraint(lessThanOrEqualToConstant: 188).isActive = true
        return label
    }
}
