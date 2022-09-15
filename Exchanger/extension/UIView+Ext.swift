//
//  UIView+Ext.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-15.
//

import UIKit

extension UIView {
  func addGradientBackground() {
    let colorLeft = UIColor.systemOrange.cgColor
    let colorRight = UIColor.systemRed.cgColor

    let gradientLayer = CAGradientLayer()
    gradientLayer.cornerRadius = 10
    gradientLayer.masksToBounds = true
    gradientLayer.colors = [colorLeft, colorRight]
    gradientLayer.locations = [0.0, 1.0]
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
    gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
    gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
    self.layer.insertSublayer(gradientLayer, at: 0)
  }

  func addShadow() {
    layer.shadowColor = UIColor.label.cgColor
    layer.shadowOffset = CGSize(width: 2, height: 2)
    layer.shadowRadius = 2.0
    layer.shadowOpacity = 0.3
    layer.masksToBounds = false
  }
}
