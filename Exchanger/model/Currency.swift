//
//  Currency.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-14.
//

import Foundation

struct Currency: Hashable {
  let symbol: String
  let abbreviation: String
  let balance: Int

  func hash(into hasher: inout Hasher) {
    hasher.combine(abbreviation)
  }
}
