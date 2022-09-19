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
  // to host the scrollview
  let contentView = UIView()
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
  ///  Using EUR as the initial, since we'll have at least two currency to exchange
  @Published var fromCurrency: String = CurrencyEnums.eurAbbr.rawValue
  /// to store the value of "To"
  ///  Using USD as the second, since we'll have at least two currency to exchange
  @Published var toCurrency: String = CurrencyEnums.usdAbbr.rawValue
  /// to store the currencyAmount user inputed on our TF
  @Published var amountOfExchange: Double = 0

  /// holds our current balances
  /// add new currency here later
  @Published var availableUsdBalance: Double = 0
  @Published var availableEurBalance: Double = 0
  @Published var availableJpyBalance: Double = 0
  @Published var exchangeItem: Exchange?

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
    setJpyBalancePublisher()

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
        self.disableExchangeButton()
        // check if user has balance in from currency
        if !self.isSelectedFromAvailable() {
          self.updateMessage(with: MessageType.zeroBalance.rawValue, color: .systemRed)
          return 0.0
        }

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
      .filter { $0 > 0 }
      .map {
        self.exchangeCurrencyOf($0, from: self.fromCurrency, to: self.toCurrency)
      }
      .sink { _ in
        print("Call Done from Currency Amount")
      }
      .store(in: &self.cancellables)
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

  func exchangeCurrencyOf(_ amount: Double, from input: String, to output: String) {
    // swiftlint:disable:next force_unwrapping
    let url = URL(string: "http://api.evp.lt/currency/commercial/exchange/\(amount)-\(input)/\(output)/latest")!
    self.updateMessage(with: MessageType.working.rawValue, color: .systemGreen)
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
      .map { exchange -> Bool in
        if !self.isExchangePossible() {
          self.updateMessage(with: MessageType.notEnoughBalance.rawValue, color: .systemRed)
          return false
        }

        self.updateMessage(
          with:
          """
          You'll receive \(exchange.amount) \(exchange.currency) for \(amount) \(input),
          \(self.calculateFee(amount)) \(input) fee will be deducted
          """,
          color: .systemGreen)

        // set the exchange item
        self.exchangeItem = exchange

        return true
      }
      .sink { _ in
        print("Finished Network call")
      } receiveValue: { value in
        if !value {
          self.disableExchangeButton()
        } else {
          DispatchQueue.main.async {
            // enable the button
            self.exchangeButton.backgroundColor = .systemOrange
            self.exchangeButton.isEnabled = true
          }
        }
      }
      .store(in: &self.cancellables)
  }

  // MARK: UI Events

  @objc func exchangeButtonDidTapped(_ sender: UIButton) {
    if exchangeItem != nil {
      // add the exchanged amount
      addExchangedAmount()

      // deduct the balance we're exchanging
      deductExchangingAmount()

      // update the exchange count
      userDefault.exchangeCount += 1

      // reset everything
      currencyAmountTF.text = ""
      amountOfExchange = 0
    }
  }

  @objc func textFieldChanged() {
    amountOfExchange = Double(currencyAmountTF.text ?? "0") ?? 0.0
  }

  // MARK: Add New Currencies Here

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
        if let row = self.myCurrencies.firstIndex(where: { $0.abbreviation == CurrencyEnums.eurAbbr.rawValue }) {
          let newItem = Currency(
            symbol: self.myCurrencies[row].symbol,
            abbreviation: self.myCurrencies[row].abbreviation,
            balance: value.round(to: 2))
          // update the currency in collection
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
        if let row = self.myCurrencies.firstIndex(where: { $0.abbreviation == CurrencyEnums.usdAbbr.rawValue }) {
          let newItem = Currency(
            symbol: self.myCurrencies[row].symbol,
            abbreviation: self.myCurrencies[row].abbreviation,
            balance: value.round(to: 2))
          // update the currency in collection
          self.myCurrencies[row] = newItem
        }

        self.updateCollectionView()
      }
      .store(in: &cancellables)
  }

  /// JPY
  func setJpyBalancePublisher() {
    userDefault
      .publisher(for: \.jpyBalance)
      .removeDuplicates()
      .map { currentValue in
        // Return the value if it's greater than 0, else returns 0
        // a caution against neg values
        currentValue > 0 ? currentValue : 0
      }
      .sink { value in
        self.availableJpyBalance = value
        if let row = self.myCurrencies.firstIndex(where: { $0.abbreviation == CurrencyEnums.jpyAbbr.rawValue }) {
          let newItem = Currency(
            symbol: self.myCurrencies[row].symbol,
            abbreviation: self.myCurrencies[row].abbreviation,
            balance: value.round(to: 2))
          // update the currency in collection
          self.myCurrencies[row] = newItem
        }
        print(self.myCurrencies)
        self.updateCollectionView()
      }
      .store(in: &cancellables)
  }
}
