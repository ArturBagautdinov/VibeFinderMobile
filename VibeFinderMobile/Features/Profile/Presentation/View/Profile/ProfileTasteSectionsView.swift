//
//  ProfileTasteSectionsView.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 15.09.2026.
//

import Foundation
import UIKit

final class ProfileTasteSectionsView: UIView {
    
    private nonisolated enum Section {
        case main
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, ProfileInfoSectionDisplayModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ProfileInfoSectionDisplayModel>
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeLayout()
    )
    
    private lazy var dataSource = makeDataSource()
    
    init(sections: [ProfileInfoSectionDisplayModel]) {
        super.init(frame: .zero)
        configure()
        render(sections)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    func render(_ sections: [ProfileInfoSectionDisplayModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(sections.filter { !$0.items.isEmpty }, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(220),
            heightDimension: .fractionalHeight(1)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(220), heightDimension: .absolute(250))
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func makeDataSource() -> DataSource {
        let registration = UICollectionView.CellRegistration<
            ProfileTasteSectionCell,
            ProfileInfoSectionDisplayModel
        > { cell, _, section in
            cell.configure(with: section)
        }
        
        return DataSource(collectionView: collectionView) { collectionView, indexPath, section in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: section
            )
        }
        
    }
    
}
