//
//  UserDefaults+Ext.swift
//  Exchanger
//
//  Created by Mahmudul Hasan on 2022-09-18.
//

import Foundation

extension UserDefaults {
  /// Add each currency we have
    @objc var usdBalance: Double {
      get {
        return double(forKey: "usdBalance")
      }
      set {
        set(newValue, forKey: "usdBalance")
      }
    }

  @objc var eurBalance: Double {
    get {
      return double(forKey: "eurBalance")
    }
    set {
      set(newValue, forKey: "eurBalance")
    }
  }

  @objc var jpyBalance: Double {
    get {
      return double(forKey: "jpyBalance")
    }
    set {
      set(newValue, forKey: "jpyBalance")
    }
  }
}
