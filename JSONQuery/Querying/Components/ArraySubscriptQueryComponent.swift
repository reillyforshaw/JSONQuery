//
//  ArraySubscriptQueryComponent.swift
//  JSONQuery
//
//  Created by Reilly Forshaw on 2018-03-29.
//  Copyright © 2018 Reilly Forshaw. All rights reserved.
//

import Foundation

public struct ArraySubscriptQueryComponent : JSONQueryComponent {
  public let index: Int
  
  public func evaluate(on object: Any) -> Any? {
    return (object as? [Any]).flatMap { index < $0.endIndex ? $0[index] : nil }
  }
}
