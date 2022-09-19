//
//  Double+Ext.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-19.
//

import Foundation

extension Double {
  func round(to decimalPlaces: Int) -> Double {
    let precisionNumber = pow(10, Double(decimalPlaces))
    var current = self // self is a current value of the Double that you will round
    current *= precisionNumber
    current.round()
    current /= precisionNumber
    return current
  }
}
