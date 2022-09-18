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
  // to input the amount user want to exchange
  var currencyAmountTF: UITextField!
  // to exchange the currency
  var exchangeButton: UIButton!
  // just an ordinary activity indicator
  var activityIndicator: UIActivityIndicatorView!
  var layoutGuide: UILayoutGuide!
  // swiftlint:enable implicitly_unwrapped_optional
  // Currencies the app supports
  var availableCurrencies = Utils.availableCurrencies()
  // to store our cancellables
  private var cancellables = Set<AnyCancellable>()
  // to update our activity indicator
  var activityPublisher = PassthroughSubject<Bool, Never>()

  /// title for second section
  let exchangeTitle = TitleLabel(size: 20)
  let messageTitle = TitleLabel(size: 14, color: .systemOrange)
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

  let fromArrowIv = UIImageView(image: UIImage(systemName: "chevron.down"))
  let toArrowIv = UIImageView(image: UIImage(systemName: "chevron.down"))

  /// to store the value of "From"
  ///  Using USD as the initial, since we'll have at least two currency to exchange
  @Published var fromCurrency: String = "USD"
  /// to store the value of "To"
  ///  Using EUR as the second, since we'll have at least two currency to exchange
  @Published var toCurrency: String = "EUR"
  /// to store the currencyAmount user inputed on our TF
  @Published var amountOfExchange: Double = 0

  /// Constant for padding/margining views
  let contentPadding: CGFloat = 20

  /// validates our currency input and updates the UI according to the value
  var currencyAmount: AnyPublisher<Double, Never> {
    return $amountOfExchange.map { value in
      guard value > 0 else {
        DispatchQueue.main.async {
          self.messageTitle.text = "Ready!"
          self.messageTitle.textColor = .systemOrange
          self.activityPublisher.send(false)
        }
        return 0
      }

      DispatchQueue.main.async {
        self.messageTitle.text = "Ready to fire!"
        self.messageTitle.textColor = .systemOrange
      }

      return value
    }
    .eraseToAnyPublisher()
  } // end of validateCurrencyAmount

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    self.title = "Exchanger"
    navigationController?.navigationBar.prefersLargeTitles = true

    layoutGuide = view.safeAreaLayoutGuide

    configureCollectionView()
    configureDataSource()
    updateCollectionView()
    // adding the section title
    configureExchangeTitle()
    // adding activity indicator
    configureActivityIndicator()
    // adding the message label that'll display many status
    configureMessageTitle()
    // configuring the from button
    configureFromButton()
    // configuring the to button
    configureToButton()
    // the arrows for UX and decoration
    configureArrowImages()
    // configuring the TextField to take user input
    configureInputTF()
    // configure the exchange button
    configureExhangeButton()

    // To update the message label when amount or currency changes
    currencyAmount
      .combineLatest($fromCurrency, $toCurrency)
      .map { tuple in
        self.fromCurrency = tuple.1
        self.toCurrency = tuple.2
        return tuple.0
      }
      .debounce(for: .milliseconds(1000), scheduler: RunLoop.main)
      .map {
        if $0 > 0 {
          // enable the button
          self.exchangeButton.backgroundColor = .systemOrange
          self.exchangeButton.isEnabled = true
        } else {
          // disable the button
          self.exchangeButton.backgroundColor = .systemOrange.withAlphaComponent(0.5)
          self.exchangeButton.isEnabled = false
        }
        return $0
      }
      .filter { $0 > 0 }
      .map {
        self.exchangeCurrencyOf($0, from: self.fromCurrency, to: self.toCurrency)
      }
      .sink { _ in
        print("Call Done from Currency Amount")
      }
      .store(in: &self.cancellables)

    // to show status
    activityPublisher
      .receive(on: RunLoop.main)
      .sink { isWorking in
        if isWorking {
          self.activityIndicator.startAnimating()
        } else {
          self.activityIndicator.stopAnimating()
        }
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

  func exchangeCurrencyOf(_ amount: Double, from input: String, to output: String) {
    // swiftlint:disable:next force_unwrapping
    let url = URL(string: "http://api.evp.lt/currency/commercial/exchange/\(amount)-\(input)/\(output)/latest")!
    // swiftlint:disable:next array_init
    URLSession.shared.dataTaskPublisher(for: url)
      .handleEvents(receiveSubscription: { _ in
        self.activityPublisher.send(true)
      }, receiveCompletion: { _ in
        self.activityPublisher.send(false)
      }, receiveCancel: {
        self.activityPublisher.send(false)
      })
      .tryMap { output -> Data in
        guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
          DispatchQueue.main.async {
            self.messageTitle.text = "Error with Network Response"
            self.messageTitle.textColor = .systemRed
          }
          self.activityPublisher.send(false)
          throw URLError(.badServerResponse)
        }
        return output.data
      }
      .decode(type: Exchange.self, decoder: JSONDecoder())
      .map {
        $0
      }
      .map { exchange in
        DispatchQueue.main.async {
          self.messageTitle.text = "\(amount) \(self.fromCurrency) = \(exchange.amount) \(self.toCurrency)"
          self.messageTitle.textColor = .systemGreen
        }
      }
      .sink { _ in
        print("Done")
      } receiveValue: { _ in
        print("Call Done")
      }
      .store(in: &self.cancellables)
  }

  @objc func exchangeButtonDidTapped(_ sender: UIButton) {
    print("did tapped")
  }

  @objc func textFieldChanged() {
    amountOfExchange = Double(currencyAmountTF.text ?? "0") ?? 0.0
  }
}
