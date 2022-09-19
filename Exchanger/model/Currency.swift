//
//  Currency.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-14.
//

import Foundation

class Currency: Hashable {
  let symbol: String
  let abbreviation: String
  @Published var balance: Double

  init(symbol: String, abbreviation: String, balance: Double) {
    self.symbol = symbol
    self.abbreviation = abbreviation
    self.balance = balance
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
    hasher.combine(identifier)
  }

  static func == (lhs: Currency, rhs: Currency) -> Bool {
    return lhs.identifier == rhs.identifier && lhs.balance == rhs.balance
  }

  private let identifier = UUID()
}
