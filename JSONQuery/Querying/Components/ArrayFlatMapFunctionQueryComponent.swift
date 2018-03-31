//
//  ArrayFlatMapFunctionQueryComponent
//  JSONQuery
//
//  Created by Reilly Forshaw on 2018-03-29.
//  Copyright © 2018 Reilly Forshaw. All rights reserved.
//

import Foundation

struct ArrayFlatMapFunctionQueryComponent : JSONQueryComponent {
  let transform: JSONQuery
  
  func evaluate(on object: Any) -> Any? {
    return (object as? [Any]).map { $0.flatMap { transform.evaluate(on: $0) } }
  }
}
