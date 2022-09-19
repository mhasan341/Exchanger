//
//  MessageType.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-19.
//

import Foundation

enum MessageType: String {
  case ready = "Ready"
  case readyAndWaiting = "Ready To Fire!"
  case sameCurrency = "Currencies must be different"
  case networkError = "Error with Network Response"
  case anError = "An error occured while exchanging"
}
