//
//  DictionaryKeysFunctionQueryComponent.swift
//  JSONQuery
//
//  Created by Reilly Forshaw on 2018-03-29.
//  Copyright © 2018 Reilly Forshaw. All rights reserved.
//

import Foundation

public struct DictionaryKeysFunctionQueryComponent : JSONQueryComponent {
  public func evaluate(on object: Any) -> Any? {
    guard let keys = (object as? [String : Any])?.keys else { return nil }
    return Array(keys)
  }
}
