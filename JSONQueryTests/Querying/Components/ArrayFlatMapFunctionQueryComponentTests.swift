//
//  ArrayFlatMapFunctionQueryComponentTests.swift
//  JSONQueryTests
//
//  Created by Reilly Forshaw on 2018-03-29.
//  Copyright © 2018 Reilly Forshaw. All rights reserved.
//

import Foundation
import XCTest

@testable import JSONQuery

class ArrayFlatMapFunctionQueryComponentTests : XCTestCase {
  func testEvaluatingEmptyQueryOnNonArray() {
    let comp = ArrayFlatMapFunctionQueryComponent(transform: [])
    
    XCTAssertNil(comp.evaluate(on: [:]))
  }
  
  func testEvaluatingNonEmptyQueryOnNonArray() {
    let comp = ArrayFlatMapFunctionQueryComponent(transform: [DictionarySubscriptQueryComponent(key: "foo")])
    
    XCTAssertNil(comp.evaluate(on: [:]))
  }
  
  func testEvaluatingOnEmptyArray() {
    let comp = ArrayFlatMapFunctionQueryComponent(transform: [DictionarySubscriptQueryComponent(key: "foo")])
    
    XCTAssertTrue((comp.evaluate(on: []) as! [Any]).isEmpty)
  }
  
  func testEvaluatingOnArrayWhereKeyDoesNotMatch() {
    let comp = ArrayFlatMapFunctionQueryComponent(transform: [DictionarySubscriptQueryComponent(key: "foo")])
    
    XCTAssertTrue((comp.evaluate(on: [["bar" : 1]]) as! [Any]).isEmpty)
  }
  
  func testEvaluatingOnArrayWhereKeyMatches() {
    let comp = ArrayFlatMapFunctionQueryComponent(transform: [DictionarySubscriptQueryComponent(key: "foo")])
    
    XCTAssertEqual(comp.evaluate(on: [["foo" : 1]]) as! [Int], [1])
  }
}
