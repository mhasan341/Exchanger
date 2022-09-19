//
//  MainVC+Ext.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-15.
//

import UIKit

extension MainVC: UICollectionViewDelegate {
  /// calls different functions that lays out the layout of the app
  func doInitialSetup(){
    layoutGuide = view.safeAreaLayoutGuide
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
  
  /// CollectionView that holds the balance cards
  func configureCollectionView() {
    let contentView = UIView()
    view.addSubview(contentView)

    contentView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: contentPadding),
      contentView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: contentPadding),
      contentView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -contentPadding),
      contentView.heightAnchor.constraint(equalToConstant: 150)
    ])


    // invalidate the frames
    contentView.layoutIfNeeded()

    collectionView = UICollectionView(frame: contentView.bounds, collectionViewLayout: Utils.createBalanceCardLayout())

    contentView.addSubview(collectionView)

    collectionView.autoresizingMask = .flexibleHeight

    collectionView.delegate = self

    collectionView.register(BalanceCardCell.self, forCellWithReuseIdentifier: BalanceCardCell.reuseID)

    collectionView.register(
      BalanceSectionHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: BalanceSectionHeaderView.reuseIdentifier
    )
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
    view.addSubview(exchangeTitle)
    exchangeTitle.text = "Currency Exchange"

    NSLayoutConstraint.activate([
      exchangeTitle.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: contentPadding),
      exchangeTitle.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: contentPadding)
    ])
  }

  /// Displays our activity status
  func configureActivityIndicator() {
    activityIndicator = UIActivityIndicatorView()
    view.addSubview(activityIndicator)
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      activityIndicator.topAnchor.constraint(equalTo: exchangeTitle.bottomAnchor, constant: contentPadding / 2),
      activityIndicator.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -contentPadding)
    ])
  }

  /// Adds a Message Label that'll display different status
  func configureMessageTitle() {
    view.addSubview(messageTitle)

    NSLayoutConstraint.activate([
      messageTitle.topAnchor.constraint(equalTo: exchangeTitle.bottomAnchor, constant: contentPadding / 2),
      messageTitle.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: contentPadding),
      messageTitle.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -contentPadding)
    ])
    messageTitle.textAlignment = .center
    messageTitle.numberOfLines = 2
  }

  /// Adds the from dropdown currency selector
  func configureFromButton() {
    let fromLabel = SecondaryTitleLabel(size: 14)
    view.addSubview(fromLabel)
    fromLabel.text = "From"
    view.addSubview(fromCurrencyButton)

    NSLayoutConstraint.activate([
      fromLabel.topAnchor.constraint(equalTo: messageTitle.bottomAnchor, constant: contentPadding / 2),
      fromLabel.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: contentPadding),

      fromCurrencyButton.topAnchor.constraint(equalTo: fromLabel.bottomAnchor, constant: 0),
      fromCurrencyButton.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: contentPadding)
    ])
  }

  /// Adds the from dropdown currency selector
  func configureToButton() {
    let toLabel = SecondaryTitleLabel(size: 14)
    view.addSubview(toLabel)
    toLabel.text = "To"
    view.addSubview(toCurrencyButton)

    NSLayoutConstraint.activate([
      toLabel.topAnchor.constraint(equalTo: messageTitle.bottomAnchor, constant: contentPadding / 2),
      toLabel.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -contentPadding),

      toCurrencyButton.topAnchor.constraint(equalTo: toLabel.bottomAnchor, constant: 0),
      toCurrencyButton.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -contentPadding)
    ])
  }

  func configureArrowImages() {
    view.addSubview(fromArrowIv)
    view.addSubview(toArrowIv)

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
    view.addSubview(currencyAmountTF)
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
    view.addSubview(exchangeButton)
    exchangeButton.translatesAutoresizingMaskIntoConstraints = false

    exchangeButton.setTitle("Exchange", for: .normal)
    exchangeButton.addTarget(self, action: #selector(exchangeButtonDidTapped), for: .touchUpInside)
    exchangeButton.backgroundColor = .systemOrange
    exchangeButton.layer.cornerRadius = 8.0
    exchangeButton.layer.masksToBounds = true

    NSLayoutConstraint.activate([
      exchangeButton.topAnchor.constraint(equalTo: currencyAmountTF.bottomAnchor, constant: contentPadding / 2),
      exchangeButton.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: contentPadding),
      exchangeButton.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -contentPadding)
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
}
