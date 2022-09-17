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
  /// title for second section
  let exchangeTitle = TitleLabel(size: 20)
  let messageTitle = TitleLabel(size: 16, color: .systemOrange)

  /// button for the from menu
  lazy var fromCurrencyButton: UIButton = {
    let button = UIButton(frame: .zero)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(availableCurrencies[0].abbreviation, for: .normal)
    button.showsMenuAsPrimaryAction = true
    button.menu = UIMenu(children: fromMenuAction())
    button.setTitleColor(UIColor.black, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    return button
  }()

  /// button for the to menu
  lazy var toCurrencyButton: UIButton = {
    let button = UIButton(frame: .zero)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(availableCurrencies[1].abbreviation, for: .normal)
    button.showsMenuAsPrimaryAction = true
    button.menu = UIMenu(children: toMenuActions())
    button.setTitleColor(UIColor.black, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    return button
  }()

  /// to store the value of "From"
  ///  Using USD as the initial, since we'll have at least two currency to exchange
  @Published var fromCurrency: String = "USD"
  /// to store the value of "To"
  ///  Using EUR as the second, since we'll have at least two currency to exchange
  @Published var toCurrency: String = "EUR"

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
    // adding the section title
    configureExchangeTitle()
    // adding the message label that'll display many status
    configureMessageTitle()
    // configuring the from button
    configureFromButton()
    // con

    // To test
    $fromCurrency.sink { from in
      print(from)
    }
    .store(in: &cancellables)
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
