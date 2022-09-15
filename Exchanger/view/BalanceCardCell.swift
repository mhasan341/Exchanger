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
  private let symbolLabel = TitleLabel(fontSize: 24, fontColor: .white)
  /// Holds the abbr of the currency name, eg: USD
  private let abbrLabel = SecondaryTitleLabel(fontSize: 20)
  /// Holds the current balance of this currency, eg: "1000"
  private let balanceLabel = TitleLabel(fontSize: 20, fontColor: .white)

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

    // for rounder corners
    layer.cornerRadius = cornerRadius
    layer.masksToBounds = true

    // change these two value
    symbolLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    balanceLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)

    NSLayoutConstraint.activate([
      symbolLabel.topAnchor.constraint(equalTo: topAnchor, constant: contentPadding),
      symbolLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentPadding),

      abbrLabel.topAnchor.constraint(equalTo: topAnchor, constant: contentPadding),
      abbrLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentPadding),

      balanceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentPadding),
      balanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentPadding)
    ])
  }

  /// We're adding a shadow and background for better UI
  override func layoutSubviews() {
    super.layoutSubviews()
    self.addGradientBackground()
    addShadow()
  }

  /// Sets the values of this cell
  func set(_ item: Currency) {
    symbolLabel.text = item.symbol
    abbrLabel.text = item.abbreviation
    balanceLabel.text = "\(item.balance)"
  }
}
