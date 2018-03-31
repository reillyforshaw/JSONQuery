//
//  ArraySubscriptQueryComponentTests.swift
//  JSONQueryTests
//
//  Created by Reilly Forshaw on 2018-03-29.
//  Copyright © 2018 Reilly Forshaw. All rights reserved.
//

import Foundation
import XCTest

@testable import JSONQuery

class ArraySubscriptQueryComponentTests : XCTestCase {
  func testEvaluatingOnEmptyArray() {
    let comp = ArraySubscriptQueryComponent(index: 0)
    
    XCTAssertNil(comp.evaluate(on: []))
  }
  
  func testEvaluatingOnArrayContainingObjectAtIndex() {
    let comp = ArraySubscriptQueryComponent(index: 0)
    
    XCTAssertEqual(comp.evaluate(on: ["foo"]) as! String, "foo")
  }
}
