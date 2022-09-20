//
//  UIViewController+Ext.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-20.
//

import UIKit

extension UIViewController {
  // to dismiss the keyboard
  func hideKeyboardOnOutsideTouch() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}
