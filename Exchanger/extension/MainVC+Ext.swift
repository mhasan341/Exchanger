//
//  MainVC+Ext.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-15.
//

import UIKit

extension MainVC: UICollectionViewDelegate {
  /// CollectionView that holds the balance cards
  func configureCollectionView() {
    let contentView = UIView()
    view.addSubview(contentView)

    contentView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: contentPadding),
      contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: contentPadding),
      // swiftlint:disable:next line_length
      contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -contentPadding),
      contentView.heightAnchor.constraint(equalToConstant: 150)
    ])


    // invalidate the frames
    contentView.layoutIfNeeded()

    collectionView = UICollectionView(frame: contentView.bounds, collectionViewLayout: Utils.createBalanceCardLayout())

    contentView.addSubview(collectionView)

    collectionView.autoresizingMask = .flexibleHeight

    collectionView.delegate = self

    collectionView.register(BalanceCardCell.self, forCellWithReuseIdentifier: BalanceCardCell.reuseID)

    collectionView.register(
      BalanceSectionHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: BalanceSectionHeaderView.reuseIdentifier
    )
  }

  /// DataSource for the collectionView
  func configureDataSource() {
    // swiftlint:disable line_length
    dataSource = UICollectionViewDiffableDataSource<Section, Currency>(collectionView: collectionView) { collectionView, indexPath, item in
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BalanceCardCell.reuseID, for: indexPath) as? BalanceCardCell else {fatalError("Error dequeueing cell")}

      cell.set(self.availableCurrencies[indexPath.item])
      return cell
    }
    // swiftlint:enable line_length

    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      guard kind == UICollectionView.elementKindSectionHeader else {
        return UICollectionReusableView()
      }

      let view = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: BalanceSectionHeaderView.reuseIdentifier,
        for: indexPath) as? BalanceSectionHeaderView

      let section = self.dataSource.snapshot()
        .sectionIdentifiers[indexPath.section]

      view?.sectionTitleLabel.text = section.title

      return view
    }
  }
}
