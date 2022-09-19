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
  // MARK: UI Elements
  // Stores my balance cards
  var collectionView: UICollectionView!
  var dataSource: UICollectionViewDiffableDataSource<Section, Currency>!
  // to input the amount user want to exchange
  var currencyAmountTF: UITextField!
  // to exchange the currency
  var exchangeButton: UIButton!
  // just an ordinary activity indicator
  var activityIndicator: UIActivityIndicatorView!
  // helps reducing line limit
  var layoutGuide: UILayoutGuide!
  // swiftlint:enable implicitly_unwrapped_optional
  /// title for second section
  let exchangeTitle = TitleLabel(size: 20)
  let messageTitle = TitleLabel(size: 14, color: .systemOrange)
  /// button for the from menu, EUR as default
  lazy var fromCurrencyButton: UIButton = {
    let button = UIButton(frame: .zero)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(myCurrencies[1].abbreviation, for: .normal)
    button.showsMenuAsPrimaryAction = true
    button.menu = UIMenu(children: fromMenuAction())
    button.setTitleColor(UIColor.black, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    return button
  }()

  /// button for the to menu, USD as default
  lazy var toCurrencyButton: UIButton = {
    let button = UIButton(frame: .zero)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(myCurrencies[0].abbreviation, for: .normal)
    button.showsMenuAsPrimaryAction = true
    button.menu = UIMenu(children: toMenuActions())
    button.setTitleColor(UIColor.black, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    return button
  }()

  let fromArrowIv = UIImageView(image: UIImage(systemName: "chevron.down"))
  let toArrowIv = UIImageView(image: UIImage(systemName: "chevron.down"))

  // MARK: Combine

  // to store our cancellables
  private var cancellables = Set<AnyCancellable>()
  // to update our activity indicator
  var activityPublisher = PassthroughSubject<Bool, Never>()
  /// to store the value of "From"
  ///  Using USD as the initial, since we'll have at least two currency to exchange
  @Published var fromCurrency: String = "EUR"
  /// to store the value of "To"
  ///  Using EUR as the second, since we'll have at least two currency to exchange
  @Published var toCurrency: String = "USD"
  /// to store the currencyAmount user inputed on our TF
  @Published var amountOfExchange: Double = 0

  /// holds our current balances
  /// add new currency here later
  @Published var availableUsdBalance: Double = 0
  @Published var availableEurBalance: Double = 0
  @Published var availableJpyBalance: Double = 0

  // MARK: Everything else
  /// Constant for padding/margining views
  let contentPadding: CGFloat = 20
  // Currencies the app supports
  lazy var myCurrencies = availableCurrencies()
  // user default for managing balance and update
  let userDefault = UserDefaults.standard

  /// validates our currency input and updates the UI according to the value
  var currencyAmount: AnyPublisher<Double, Never> {
    return $amountOfExchange.map { value in
      guard value > 0 else {
        self.updateMessage(with: MessageType.ready.rawValue, color: .systemOrange)
          self.activityPublisher.send(false)

        return 0
      }

      self.updateMessage(with: MessageType.readyAndWaiting.rawValue, color: .systemOrange)

      return value
    }
    .eraseToAnyPublisher()
  } // end of validateCurrencyAmount

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    self.title = "Exchanger"
    navigationController?.navigationBar.prefersLargeTitles = true

    /// Sets the whole layout
    doInitialSetup()

    /// Check if it's first run and save the initial balance
    if !userDefault.bool(forKey: "first_run_done") {
      userDefault.set(true, forKey: "first_run_done")
      userDefault.eurBalance = 1000
    }


    // To update the Collection view on these balance change
    setEurBalancePublisher()
    setUsdBalancePublisher()

    // To update the message label when amount or currency changes
    setCurrencyAmountPublisher()
    // State of our network call
    setActivityPublisher()
  }

  func setCurrencyAmountPublisher() {
    currencyAmount
      .combineLatest($fromCurrency, $toCurrency)
      .map { tuple in
        self.fromCurrency = tuple.1
        self.toCurrency = tuple.2

        if tuple.1 == tuple.2 {
          print("Same Currency")
          self.updateMessage(with: MessageType.sameCurrency.rawValue, color: .systemRed)
          return 0.0
        } else {
          self.updateMessage(with: MessageType.ready.rawValue, color: .systemOrange)
        }

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
  }

  /// EUR
  func setEurBalancePublisher() {
    userDefault
      .publisher(for: \.eurBalance)
      .removeDuplicates()
      .map { currentValue in
        // Return the value if it's greater than 0, else returns 0
        // a caution against neg values
        currentValue > 0 ? currentValue : 0
      }
      .sink { value in
        self.availableEurBalance = value
        if let row = self.myCurrencies.firstIndex(where: {$0.abbreviation == "EUR"}) {
          let newItem = Currency(symbol: self.myCurrencies[row].symbol, abbreviation: self.myCurrencies[row].abbreviation, balance: value.round(to: 2))
          self.myCurrencies[row] = newItem
        }

        self.updateCollectionView()
      }
      .store(in: &cancellables)
  }

  /// USD
  func setUsdBalancePublisher() {
    userDefault
      .publisher(for: \.usdBalance)
      .removeDuplicates()
      .map { currentValue in
        // Return the value if it's greater than 0, else returns 0
        // a caution against neg values
        currentValue > 0 ? currentValue : 0
      }
      .sink { value in
        self.availableUsdBalance = value
        if let row = self.myCurrencies.firstIndex(where: {$0.abbreviation == "USD"}) {
          let newItem = Currency(symbol: self.myCurrencies[row].symbol, abbreviation: self.myCurrencies[row].abbreviation, balance: value.round(to: 2))
          self.myCurrencies[row] = newItem
        }

        self.updateCollectionView()
      }
      .store(in: &cancellables)
  }

  /// to show status
  func setActivityPublisher() {
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
  func updateCollectionView() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Currency>()
    snapshot.appendSections([Section(title: Utils.balanceSection)])
    snapshot.appendItems(myCurrencies, toSection: Section(title: Utils.balanceSection))
    dataSource.apply(snapshot, animatingDifferences: true)
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
          self.updateMessage(with: MessageType.networkError.rawValue, color: .systemRed)
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
        self.updateMessage(with: "You'll receive \(exchange.amount) \(exchange.currency) for \(amount) \(input)", color: .systemGreen)
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

  /// creates currency symbol, initial balance, and abbr
  func availableCurrencies() -> [Currency] {
    var currencies: [Currency] = []
    currencies.append(Currency(symbol: "$", abbreviation: "USD", balance: availableUsdBalance))
    currencies.append(Currency(symbol: "€", abbreviation: "EUR", balance: availableEurBalance))
    currencies.append(Currency(symbol: "¥", abbreviation: "JPY", balance: availableJpyBalance))

    return currencies
  }

  /// updates the message label with the desired text and color
  /// Red: Warning/Alert
  /// Green: Something positive/Success
  /// Orange: General Info
  func updateMessage(with text: String, color textColor: UIColor) {
    DispatchQueue.main.async {
      self.messageTitle.text = text
      self.messageTitle.textColor = textColor
    }
  }
}
