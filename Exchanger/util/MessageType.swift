//
//  MessageType.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-19.
//

import Foundation

enum MessageType: String {
  case ready = "Waiting for input..."
  case working = "Fetching..."
  case sameCurrency = "Currencies must be different"
  case networkError = "Error with Network Response"
  case anError = "An error occured while exchanging"
  case zeroBalance = "You have zero balance in this account"
  case notEnoughBalance = "Your balance doesn't cover the whole exchange"
}
