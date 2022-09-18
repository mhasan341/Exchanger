//
//  UDManager.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-18.
//

import Foundation

enum UDManager {
  static private let defaults = UserDefaults.standard

  /// Returns the current balance of the saved currency
  ///  of: the currency abbr, eg: USD
  static func getCurrentBalance(of currency: String) -> Double {
    return defaults.double(forKey: currency)
  }

  /// Saves a balance for the mentioned currency
  ///  for: the currency abbr, eg: USD
  static func saveBalance(_ amount: Double, for currency: String) {
    defaults.set(amount, forKey: currency)
  }


}
