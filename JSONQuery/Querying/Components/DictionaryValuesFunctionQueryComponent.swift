//
//  DictionaryValuesFunctionQueryComponent.swift
//  JSONQuery
//
//  Created by Reilly Forshaw on 2018-03-29.
//  Copyright © 2018 Reilly Forshaw. All rights reserved.
//

import Foundation

struct DictionaryValuesFunctionQueryComponent : JSONQueryComponent {
  func evaluate(on object: Any) -> Any? {
    guard let values = (object as? [String : Any])?.values else { return nil }
    return Array(values)
  }
}
