//
//  DictionaryValuesFunctionQueryComponentTests.swift
//  JSONQueryTests
//
//  Created by Reilly Forshaw on 2018-03-29.
//  Copyright © 2018 Reilly Forshaw. All rights reserved.
//

import Foundation
import XCTest

@testable import JSONQuery

class DictionaryValuesFunctionQueryComponentTests : XCTestCase {
  func testEvaluatingOnNonDictionary() {
    let comp = DictionaryValuesFunctionQueryComponent()
    
    XCTAssertNil(comp.evaluate(on: []))
  }
  
  func testEvaluatingOnEmptyDictionary() {
    let comp = DictionaryValuesFunctionQueryComponent()
    
    XCTAssertEqual(comp.evaluate(on: [:]) as! [String], [])
  }
  
  func testEvaluatingOnNonEmptyDictionary() {
    let comp = DictionaryValuesFunctionQueryComponent()
    
    XCTAssertEqual(comp.evaluate(on: ["foo" : 1, "bar" : 2]) as! [Int], [1, 2])
  }
}
