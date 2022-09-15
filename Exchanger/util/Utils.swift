//
//  Utils.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-16.
//

import UIKit

enum Utils {
  /// Constant for the balance Section
  static let balanceSection = "Balance"
  /// Layout for the balance card view cell
  static func createBalanceCardLayout() -> UICollectionViewLayout {
    let heightDimension = NSCollectionLayoutDimension.estimated(100)

    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: heightDimension)

    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6), heightDimension: heightDimension)

    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)

    group.interItemSpacing = .fixed(10)

    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 10
    section.orthogonalScrollingBehavior = .continuous
    section.boundarySupplementaryItems = [getSectionHeader()]
    let layout = UICollectionViewCompositionalLayout(section: section)
    return layout
  }

  // MARK: For Header
  static func getSize() -> NSCollectionLayoutSize {
    return NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(10) // was 20
    )
  }

  static func getSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: getSize(),
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top
    )

    header.pinToVisibleBounds = true

    return header
  }

  /// creates currency symbol, initial balance, and abbr
  static func availableCurrencies() -> [Currency] {
    var currencies: [Currency] = []

    currencies.append(Currency(symbol: "$", abbreviation: "USD", balance: 1000))
    currencies.append(Currency(symbol: "€", abbreviation: "EUR", balance: 0))
    currencies.append(Currency(symbol: "¥", abbreviation: "JPY", balance: 0))
    currencies.append(Currency(symbol: "C", abbreviation: "CFY", balance: 0))
    // currencies.append(Currency(symbol: "X", abbreviation: "XPY", balance: 0))

    return currencies
  }
}
