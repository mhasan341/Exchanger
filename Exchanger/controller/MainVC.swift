//
//  MainVC.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-14.
//

import UIKit
import Combine

class MainVC: UIViewController {
  // swiftlint:disable implicitly_unwrapped_optional
  // Stores my balance cards
  var collectionView: UICollectionView!
  var dataSource: UICollectionViewDiffableDataSource<Section, Currency>!
  // swiftlint:enable implicitly_unwrapped_optional
  // Currencies the app supports
  var availableCurrencies = Utils.availableCurrencies()
  // to store our cancellables
  private var cancellables = Set<AnyCancellable>()

  /// Constant for padding/margining views
  let contentPadding: CGFloat = 20

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    self.title = "Exchanger"
    navigationController?.navigationBar.prefersLargeTitles = true

    configureCollectionView()
    configureDataSource()
    updateCollectionView()
  }

  /// Updates the collectionView's cell
  private func updateCollectionView() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Currency>()
    snapshot.appendSections([Section(title: Utils.balanceSection)])
    snapshot.appendItems(availableCurrencies, toSection: Section(title: Utils.balanceSection))

    dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
  }


  func exchangeCurrencyOf(_ amount: String, from input: String, to output: String) {
    guard let url = URL(string: "http://api.evp.lt/currency/commercial/exchange/\(amount)-\(input)/\(output)/latest") else {return}

    URLSession.shared.dataTaskPublisher(for: url)
      .sink { error in
        print(error)
      } receiveValue: { response in
        print(response)
      }
      .store(in: &cancellables)
  }
}
