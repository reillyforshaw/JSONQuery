//
//  DictionarySubscriptQueryComponent.swift
//  JSONQuery
//
//  Created by Reilly Forshaw on 2018-03-29.
//  Copyright © 2018 Reilly Forshaw. All rights reserved.
//

import Foundation

struct DictionarySubscriptQueryComponent : JSONQueryComponent {
  let key: String
  
  func evaluate(on object: Any) -> Any? {
    return (object as? [String : Any])?[key]
  }
}
