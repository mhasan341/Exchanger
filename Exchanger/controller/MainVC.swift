//
//  MainVC.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-14.
//

import UIKit
import Combine

class MainVC: UIViewController, UICollectionViewDelegate {
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
  private var contentPadding: CGFloat = 20

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

  /// CollectionView that holds the balance cards
  func configureCollectionView() {
    let contentView = UIView()
    view.addSubview(contentView)

    contentView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: contentPadding),
      contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: contentPadding),
      // swiftlint:disable:next line_length
      contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -contentPadding),
      contentView.heightAnchor.constraint(equalToConstant: 100)
    ])


    // invalidate the frames
    contentView.layoutIfNeeded()

    collectionView = UICollectionView(frame: contentView.bounds, collectionViewLayout: Utils.createBalanceCardLayout())

    contentView.addSubview(collectionView)

    collectionView.autoresizingMask = .flexibleHeight

    collectionView.delegate = self

    collectionView.register(BalanceCardCell.self, forCellWithReuseIdentifier: BalanceCardCell.reuseID)
  }

  /// DataSource for the collectionView
  func configureDataSource() {
    // swiftlint:disable line_length
    dataSource = UICollectionViewDiffableDataSource<Section, Currency>(collectionView: collectionView) { collectionView, indexPath, item in
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BalanceCardCell.reuseID, for: indexPath) as? BalanceCardCell else {fatalError("Error dequeueing cell")}
      cell.set(self.availableCurrencies[indexPath.item])

      return cell
    }
    // swiftlint:enable line_length
  }
}
