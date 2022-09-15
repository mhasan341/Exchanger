//
//  BalanceSectionHeaderView.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-16.
//

import UIKit

class BalanceSectionHeaderView: UICollectionReusableView {
  static var reuseIdentifier: String {
    return String(describing: BalanceSectionHeaderView.self)
  }

  var sectionTitleLabel = TitleLabel(size: 20)


  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  private func configure() {
    backgroundColor = UIColor.systemBackground

    addSubview(sectionTitleLabel)


    NSLayoutConstraint.activate([
      sectionTitleLabel.leadingAnchor.constraint(
        equalTo: readableContentGuide.leadingAnchor, constant: -10),
      sectionTitleLabel.trailingAnchor.constraint(
        lessThanOrEqualTo: readableContentGuide.trailingAnchor),

      sectionTitleLabel.topAnchor.constraint(
        equalTo: topAnchor,
        constant: 10),
      sectionTitleLabel.bottomAnchor.constraint(
        equalTo: bottomAnchor,
        constant: -10)
    ])
  }
}
