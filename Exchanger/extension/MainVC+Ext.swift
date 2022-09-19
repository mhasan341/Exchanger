//
//  MainVC+Ext.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-15.
//

import UIKit

extension MainVC: UICollectionViewDelegate {
  /// calls different functions that lays out the layout of the app
  func doInitialSetup() {
    layoutGuide = view.safeAreaLayoutGuide
    // scrollView for the whole screen
    configureScrollView()
    // collectionView for the balance cards
    configureCollectionView()
    // data source for the collectionView
    configureDataSource()
    // updates the collectionView with our balances
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
  }

  // the scrollview
  func configureScrollView() {
    view.addSubview(scrollView)

    scrollView.translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false

    scrollView.addSubview(contentView)

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),

      contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
      contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
    ])
  }

  /// CollectionView that holds the balance cards
  func configureCollectionView() {
    let collectionContentView = UIView()
    contentView.addSubview(collectionContentView)

    collectionContentView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      collectionContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentPadding),
      collectionContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentPadding),
      collectionContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentPadding),
      collectionContentView.heightAnchor.constraint(equalToConstant: 150)
    ])


    // invalidate the frames
    collectionContentView.layoutIfNeeded()

    collectionView = UICollectionView(
      frame: collectionContentView.bounds,
      collectionViewLayout: Utils.createBalanceCardLayout())

    collectionContentView.addSubview(collectionView)

    collectionView.autoresizingMask = .flexibleHeight

    collectionView.delegate = self

    collectionView.register(BalanceCardCell.self, forCellWithReuseIdentifier: BalanceCardCell.reuseID)

    collectionView.register(
      BalanceSectionHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: BalanceSectionHeaderView.reuseIdentifier
    )
  }


  /// Updates the collectionView's cell
  func updateCollectionView() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Currency>()
    snapshot.appendSections([Section(title: Utils.balanceSection)])
    snapshot.appendItems(myCurrencies, toSection: Section(title: Utils.balanceSection))
    dataSource.apply(snapshot, animatingDifferences: true)
  }

  /// DataSource for the collectionView
  func configureDataSource() {
    // swiftlint:disable line_length
    dataSource = UICollectionViewDiffableDataSource<Section, Currency>(collectionView: collectionView) { collectionView, indexPath, item in
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BalanceCardCell.reuseID, for: indexPath) as? BalanceCardCell else {fatalError("Error dequeueing cell")}
      print("Updating Cell")
      cell.set(item)
      return cell
    }
    // swiftlint:enable line_length

    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      guard kind == UICollectionView.elementKindSectionHeader else {
        return UICollectionReusableView()
      }

      let view = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: BalanceSectionHeaderView.reuseIdentifier,
        for: indexPath) as? BalanceSectionHeaderView

      let section = self.dataSource.snapshot()
        .sectionIdentifiers[indexPath.section]

      view?.sectionTitleLabel.text = section.title

      return view
    }
  }

  /// Adds the title to view
  func configureExchangeTitle() {
    contentView.addSubview(exchangeTitle)
    exchangeTitle.text = "Currency Exchange"

    NSLayoutConstraint.activate([
      exchangeTitle.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: contentPadding),
      exchangeTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentPadding)
    ])
  }

  /// Displays our activity status
  func configureActivityIndicator() {
    activityIndicator = UIActivityIndicatorView()
    contentView.addSubview(activityIndicator)
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      activityIndicator.topAnchor.constraint(equalTo: exchangeTitle.bottomAnchor, constant: contentPadding / 2),
      activityIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentPadding)
    ])
  }

  /// Adds a Message Label that'll display different status
  func configureMessageTitle() {
    contentView.addSubview(messageTitle)

    NSLayoutConstraint.activate([
      messageTitle.topAnchor.constraint(equalTo: exchangeTitle.bottomAnchor, constant: contentPadding / 2),
      messageTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentPadding),
      messageTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentPadding)
    ])
    messageTitle.textAlignment = .center
    messageTitle.numberOfLines = 2
  }

  /// Adds the from dropdown currency selector
  func configureFromButton() {
    let fromLabel = SecondaryTitleLabel(size: 14)
    contentView.addSubview(fromLabel)
    fromLabel.text = "From"
    contentView.addSubview(fromCurrencyButton)

    NSLayoutConstraint.activate([
      fromLabel.topAnchor.constraint(equalTo: messageTitle.bottomAnchor, constant: contentPadding / 2),
      fromLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentPadding),

      fromCurrencyButton.topAnchor.constraint(equalTo: fromLabel.bottomAnchor, constant: 0),
      fromCurrencyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentPadding)
    ])
  }

  /// Adds the from dropdown currency selector
  func configureToButton() {
    let toLabel = SecondaryTitleLabel(size: 14)
    contentView.addSubview(toLabel)
    toLabel.text = "To"
    contentView.addSubview(toCurrencyButton)

    NSLayoutConstraint.activate([
      toLabel.topAnchor.constraint(equalTo: messageTitle.bottomAnchor, constant: contentPadding / 2),
      toLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentPadding),

      toCurrencyButton.topAnchor.constraint(equalTo: toLabel.bottomAnchor, constant: 0),
      toCurrencyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentPadding)
    ])
  }

  func configureArrowImages() {
    contentView.addSubview(fromArrowIv)
    contentView.addSubview(toArrowIv)

    fromArrowIv.translatesAutoresizingMaskIntoConstraints = false
    toArrowIv.translatesAutoresizingMaskIntoConstraints = false

    fromArrowIv.tintColor = .systemOrange
    toArrowIv.tintColor = .systemOrange

    NSLayoutConstraint.activate([
      fromArrowIv.leadingAnchor.constraint(equalTo: fromCurrencyButton.trailingAnchor, constant: 4),
      fromArrowIv.centerYAnchor.constraint(equalTo: fromCurrencyButton.centerYAnchor, constant: 0),

      toArrowIv.trailingAnchor.constraint(equalTo: toCurrencyButton.leadingAnchor, constant: -4),
      toArrowIv.centerYAnchor.constraint(equalTo: toCurrencyButton.centerYAnchor, constant: 0)
    ])
  }

  func configureInputTF() {
    currencyAmountTF = UITextField()
    contentView.addSubview(currencyAmountTF)
    currencyAmountTF.translatesAutoresizingMaskIntoConstraints = false

    currencyAmountTF.layer.borderColor = UIColor.systemGray.cgColor
    currencyAmountTF.layer.borderWidth = 1.0
    currencyAmountTF.layer.cornerRadius = 8.0
    currencyAmountTF.layer.masksToBounds = true

    currencyAmountTF.keyboardType = .decimalPad

    NSLayoutConstraint.activate([
      currencyAmountTF.leadingAnchor.constraint(equalTo: fromArrowIv.trailingAnchor, constant: contentPadding),
      currencyAmountTF.topAnchor.constraint(equalTo: messageTitle.bottomAnchor, constant: contentPadding / 2),
      currencyAmountTF.trailingAnchor.constraint(equalTo: toArrowIv.leadingAnchor, constant: -contentPadding),
      currencyAmountTF.bottomAnchor.constraint(equalTo: fromCurrencyButton.bottomAnchor, constant: 0)
    ])
    // let's add some padding
    currencyAmountTF.setLeftPaddingPoints(10)
    currencyAmountTF.setRightPaddingPoints(10)
    // we could've used a delegate, instead I choose this for simplicity
    currencyAmountTF.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
  }

  func configureExhangeButton() {
    exchangeButton = UIButton()
    contentView.addSubview(exchangeButton)
    exchangeButton.translatesAutoresizingMaskIntoConstraints = false

    exchangeButton.setTitle("Exchange", for: .normal)
    exchangeButton.addTarget(self, action: #selector(exchangeButtonDidTapped), for: .touchUpInside)
    exchangeButton.backgroundColor = .systemGray
    exchangeButton.isEnabled = false
    exchangeButton.layer.cornerRadius = 8.0
    exchangeButton.layer.masksToBounds = true

    NSLayoutConstraint.activate([
      exchangeButton.topAnchor.constraint(equalTo: currencyAmountTF.bottomAnchor, constant: contentPadding / 2),
      exchangeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentPadding),
      exchangeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentPadding)
    ])
  }

  /// Actinos for the "From" Dropdown
  func fromMenuAction() -> [UIAction] {
    var collection: [UIAction] = []
    for item in myCurrencies {
      collection.append(UIAction(title: item.abbreviation, state: .off) { action in
        self.fromCurrency = action.title
        self.fromCurrencyButton.setTitle(action.title, for: .normal)
      })
    }

    return collection
  }
  /// Actinos for the "To" Dropdown
  func toMenuActions() -> [UIAction] {
    var collection: [UIAction] = []
    for item in myCurrencies {
      collection.append(UIAction(title: item.abbreviation, state: .off) { action in
        self.toCurrency = action.title
        self.toCurrencyButton.setTitle(action.title, for: .normal)
      })
    }

    return collection
  }
  /// creates currency symbol, initial balance, and abbr
  func availableCurrencies() -> [Currency] {
    var currencies: [Currency] = []
    currencies.append(Currency(symbol: "$", abbreviation: CurrencyEnums.usdAbbr.rawValue, balance: availableUsdBalance))
    currencies.append(Currency(symbol: "€", abbreviation: CurrencyEnums.eurAbbr.rawValue, balance: availableEurBalance))
    currencies.append(Currency(symbol: "¥", abbreviation: CurrencyEnums.jpyAbbr.rawValue, balance: availableJpyBalance))

    return currencies
  }

  /// updates the message label with the desired text and color
  /// - Parameter color: Color that the text will have
  /// - .systemRed: Warning/Alert
  /// - .systemGreen: Something positive/Success
  /// - .systemOrange: General Info
  func updateMessage(with text: String, color textColor: UIColor) {
    DispatchQueue.main.async {
      self.messageTitle.text = text
      self.messageTitle.textColor = textColor
    }
  }
  /// returns the fee user has to pay for this conversation
  /// - Parameter amount: The amount that user exchange as "From"
  func calculateFee(_ amount: Double) -> Double {
    // we have a flat fee of 0.7 %
    var fee = 0.007

    // get the exchange count and adjust our fee according to that
    // we could make every condition simple one liner, but for future refactoring
    // seperate condition makes sense

    // fee below 5 exchange is free
    if userDefault.exchangeCount <= 5 {
      fee = 0
    } else if userDefault.exchangeCount % 10 == 0 {
      // every 10th exchange is free
      fee = 0
    } else if userDefault.exchangeCount % 200 == 0 {
      // every 200th exchange is free
      fee = 0
    }


    return (amount * fee).round(to: 2)
  }

  /// adds the exchanged amount to the balance
  func addExchangedAmount() {
    if let exchangeItem = exchangeItem {
      print("Adding")
      let currencyToAdd = CurrencyEnums(rawValue: exchangeItem.currency)
      switch currencyToAdd {
      case .usdAbbr:
        userDefault.usdBalance += Double(exchangeItem.amount) ?? 0
      case .eurAbbr:
        userDefault.eurBalance += Double(exchangeItem.amount) ?? 0
      case .jpyAbbr:
        userDefault.jpyBalance += Double(exchangeItem.amount) ?? 0
      case .none:
        print("None matched")
        updateMessage(with: MessageType.anError.rawValue, color: .systemRed)
      }
    } else {
      print("Exchange is nil")
    }
  }

  /// deducts the amount we're exchangin from balance
  func deductExchangingAmount() {
    // how much in total to deduct
    let totalAmountToDeduct = self.calculateFee(amountOfExchange) + amountOfExchange

    let currencyToDeduct = CurrencyEnums(rawValue: fromCurrency)
    switch currencyToDeduct {
    case .usdAbbr:
      userDefault.usdBalance -= totalAmountToDeduct
    case .eurAbbr:
      userDefault.eurBalance -= totalAmountToDeduct
    case .jpyAbbr:
      userDefault.jpyBalance -= totalAmountToDeduct
    case .none:
      print("None matched")
      updateMessage(with: MessageType.anError.rawValue, color: .systemRed)
    }
  }

  /// checks if user has any balance available for exchange
  func isSelectedFromAvailable() -> Bool {
    switch CurrencyEnums(rawValue: fromCurrency) {
    case .usdAbbr:
      return availableUsdBalance > 0
    case .eurAbbr:
      return availableEurBalance > 0
    case .jpyAbbr:
      return availableJpyBalance > 0
    case .none:
    print("None matched")
    }

    return false
  }

  /// checks if user's balance covers the whole exchange including fee
  func isExchangePossible() -> Bool {
    // how much in total to deduct
    let totalAmountToDeduct = self.calculateFee(amountOfExchange) + amountOfExchange

    switch CurrencyEnums(rawValue: fromCurrency) {
    case .usdAbbr:
      return availableUsdBalance >= totalAmountToDeduct
    case .eurAbbr:
      return availableEurBalance > totalAmountToDeduct
    case .jpyAbbr:
      return availableJpyBalance > totalAmountToDeduct
    case .none:
      print("None matched")
    }

    return false
  }

  /// Disables the exchange button
  func disableExchangeButton() {
    DispatchQueue.main.async {
      // disable the button
      self.exchangeButton.backgroundColor = .systemGray
      self.exchangeButton.isEnabled = false
    }
  }
}
