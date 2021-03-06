//
//  JSONQueryComponent.swift
//  JSONQuery
//
//  Created by Reilly Forshaw on 2018-03-29.
//  Copyright © 2018 Reilly Forshaw. All rights reserved.
//

import Foundation

public protocol JSONQueryComponent {
  func evaluate(on object: Any) -> Any?
}

public typealias JSONQuery = [JSONQueryComponent]

public extension Array where Element == JSONQueryComponent {
  public func evaluate(on object: Any) -> Any? {
    var next: Any? = object
    
    for component in self {
      guard let current = next else { return nil }
      next = component.evaluate(on: current)
    }
    
    return next
  }
}
