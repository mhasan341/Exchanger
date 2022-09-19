# Exchanger
Swift app to convert currencies

## Perks

- Written in Swift
- Build in around 30 working hour
- no third party framework or library is used
- built using MVC in mind, can easily be migrated to MVVM
- adding new currency is easy (Check the following section, can be reduced with some refactoring later)
  - UserDefaults+Ext.swift
  - CurrencyEnums.swift
  - availableCurrencies()
  - availableXXXBalance -> @Publisher, for managing the currency using combine
  - setXXXPublisher() -> make a new publisher for the currency mentioned above
  - addExchangedAmount()
  - deductExchangingAmount()
  - isSelectedFromAvailable()
  - isExchangePossible()

- Flexible commissioning system
- Code conforms to "Raywenderlich Swift Style Guide"

## What's Special
- Swift Reactive Programming using Combine Framework
- 100% Programmatic UI
