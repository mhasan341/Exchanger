//
//  BalanceCardView.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-14.
//

import UIKit

class BalanceCardView: UIView {
  private let contentPadding: CGFloat = 10
  private let cornerRadius: CGFloat = 8

  private let symbolLabel = TitleLabel()
  private let abbrLabel = SecondaryTitleLabel()
  private let balanceLabel = TitleLabel()

  /// Init a card with symbol, shortform, and initial balance
  init(with symbol: String, abbreviation name: String, balance amount: String) {
    super.init(frame: .zero)
    configure()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configure() {
    addSubview(symbolLabel)
    addSubview(abbrLabel)
    addSubview(balanceLabel)

    layer.cornerRadius = cornerRadius
    layer.masksToBounds = true


    NSLayoutConstraint.activate([
      symbolLabel.topAnchor.constraint(equalTo: topAnchor, constant: contentPadding),
      symbolLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentPadding),

      abbrLabel.topAnchor.constraint(equalTo: topAnchor, constant: contentPadding),
      abbrLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentPadding),

      balanceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentPadding),
      balanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentPadding),

      widthAnchor.constraint(equalToConstant: 80),
      heightAnchor.constraint(equalToConstant: 80)
    ])
  }
}
