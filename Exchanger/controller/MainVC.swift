//
//  MainVC.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-14.
//

import UIKit
import Combine

class MainVC: UIViewController {
  // Stores my balance cards
  let balanceStack = UIStackView()
  // Currencies the app supports

  // to store our cancellables
  var cancellables = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .red
    self.title = "Exchanger"
    navigationController?.navigationBar.prefersLargeTitles = true

  }

  func exchangeCurrencyOf(_ amount: String, from input: String, to output: String) {
    let url = URL(string: "http://api.evp.lt/currency/commercial/exchange/\(amount)-\(input)/\(output)/latest")

    URLSession.shared.dataTaskPublisher(for: url!)
      .sink { error in
        print(error)
      } receiveValue: { response in
        print(response)
      }
      .store(in: &cancellables)
  }

  
}
