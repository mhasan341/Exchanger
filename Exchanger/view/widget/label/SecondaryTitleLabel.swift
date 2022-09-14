//
//  SecondaryTitleLabel.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-14.
//

import UIKit

class SecondaryTitleLabel: UILabel {
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  convenience init(fontSize: CGFloat, fontColor: UIColor = .systemGray) {
    self.init(frame: .zero)
    self.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
    textColor = fontColor
  }

  private func configure() {
    isUserInteractionEnabled = true
    adjustsFontSizeToFitWidth = true
    minimumScaleFactor = 0.9
    lineBreakMode = .byTruncatingTail
    translatesAutoresizingMaskIntoConstraints = false
  }
}
