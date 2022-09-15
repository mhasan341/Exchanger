//
//  BalanceCardView.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-14.
//

import UIKit

class BalanceCardCell: UICollectionViewCell {
  /// Reuse identifier to find this cell
  static let reuseID = "balanceCardCell"
  /// Constants for this view
  private let contentPadding: CGFloat = 10
  private let cornerRadius: CGFloat = 8
  /// Holds the symbol of the currency, eg: $
  private let symbolLabel = TitleLabel(size: 24, color: .white, weight: .bold)
  /// Holds the abbr of the currency name, eg: USD
  private let abbrLabel = TitleLabel(size: 20, color: .black, weight: .heavy)
  /// Holds the current balance of this currency, eg: "1000"
  private let balanceLabel = TitleLabel(size: 20, color: .white, weight: .semibold)

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Configures the layout of this cell
  private func configure() {
    addSubview(symbolLabel)
    addSubview(abbrLabel)
    addSubview(balanceLabel)

    abbrLabel.alpha = 0.2

    NSLayoutConstraint.activate([
      symbolLabel.topAnchor.constraint(equalTo: topAnchor, constant: contentPadding),
      symbolLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentPadding),

      abbrLabel.topAnchor.constraint(equalTo: topAnchor, constant: contentPadding),
      abbrLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentPadding),

      balanceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentPadding),
      balanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentPadding)
    ])
    balanceLabel.addShadow()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    addGradientBackground()
    addShadow()
  }

  /// Sets the values of this cell
  func set(_ item: Currency) {
    symbolLabel.text = item.symbol
    abbrLabel.text = item.abbreviation
    balanceLabel.text = "\(item.balance)"
  }
}
