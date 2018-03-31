//
//  DictionarySubscriptComponentTests.swift
//  JSONQueryTests
//
//  Created by Reilly Forshaw on 2018-03-29.
//  Copyright © 2018 Reilly Forshaw. All rights reserved.
//

import Foundation
import XCTest

@testable import JSONQuery

class DictionarySubscriptQueryComponentTests : XCTestCase {
  func testEvaluatingOnEmptyDictionary() {
    let comp = DictionarySubscriptQueryComponent(key: "foo")
    
    XCTAssertNil(comp.evaluate(on: [:]))
  }
  
  func testEvaluatingOnDictionaryContainingKey() {
    let comp = DictionarySubscriptQueryComponent(key: "foo")
    
    XCTAssertEqual(comp.evaluate(on: ["foo" : "bar"]) as! String, "bar")
  }
}
