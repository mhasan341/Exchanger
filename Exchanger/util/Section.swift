//
//  Section.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-16.
//

import Foundation

struct Section: Hashable {
  let title: String

  func hash(into hasher: inout Hasher) {
    hasher.combine(title)
  }
}
