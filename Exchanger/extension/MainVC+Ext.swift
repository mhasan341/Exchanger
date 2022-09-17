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

  /// Adds the title to view
  func configureExchangeTitle() {
    view.addSubview(exchangeTitle)
    exchangeTitle.text = "Currency Exchange"

    NSLayoutConstraint.activate([
      exchangeTitle.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: contentPadding),
      exchangeTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: contentPadding)
    ])
  }

  /// Adds a Message Label that'll display different status
  func configureMessageTitle() {
    view.addSubview(messageTitle)
    messageTitle.text = "Ready!"

    NSLayoutConstraint.activate([
      messageTitle.topAnchor.constraint(equalTo: exchangeTitle.bottomAnchor, constant: contentPadding / 2),
      messageTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: contentPadding),
      messageTitle.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -contentPadding)
    ])
    messageTitle.textAlignment = .center
    messageTitle.numberOfLines = 2
  }

  /// Adds the from dropdown currency selector
  func configureFromButton() {
    let fromLabel = SecondaryTitleLabel(size: 14)
    view.addSubview(fromLabel)
    fromLabel.text = "From"
    view.addSubview(fromCurrencyButton)

    NSLayoutConstraint.activate([
      fromLabel.topAnchor.constraint(equalTo: messageTitle.bottomAnchor, constant: contentPadding / 2),
      fromLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: contentPadding),

      fromCurrencyButton.topAnchor.constraint(equalTo: fromLabel.bottomAnchor, constant: 0),
      fromCurrencyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: contentPadding)
    ])
  }

  /// Actinos for the "From" Dropdown
  func fromMenuAction() -> [UIAction] {
    var collection: [UIAction] = []
    for item in availableCurrencies {
      collection.append(UIAction(title: item.abbreviation, image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: { action in
        self.fromCurrency = action.title
        self.fromCurrencyButton.setTitle(action.title, for: .normal)
      }))
    }

    return collection
  }
  /// Actinos for the "To" Dropdown
  func toMenuActions() -> [UIAction] {
    var collection: [UIAction] = []
    for item in availableCurrencies {
      collection.append(UIAction(title: item.abbreviation, image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: { action in
        self.toCurrency = action.title
      }))
    }

    return collection
  }
}
