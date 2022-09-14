//
//  TitleLabel.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-14.
//

import UIKit

class TitleLabel: UILabel {
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  convenience init(fontSize: CGFloat, fontColor: UIColor = .black) {
    self.init(frame: .zero)
    self.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
    textColor = fontColor
  }

  private func configure() {
    lineBreakMode = .byTruncatingTail
    translatesAutoresizingMaskIntoConstraints = false
    numberOfLines = 1
  }
}
