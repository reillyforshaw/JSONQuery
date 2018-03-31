//
//  JSONQueryComponentTests.swift
//  JSONQueryTests
//
//  Created by Reilly Forshaw on 2018-03-29.
//  Copyright © 2018 Reilly Forshaw. All rights reserved.
//

import Foundation
import XCTest

@testable import JSONQuery

class JSONQueryComponentTests : XCTestCase {
  let exampleJSON: [String : Any] = [
    "response" : [
      "status_code" : 200,
      "users" : [
        [ "id" : 1, "name" : "User 1" , "avatar" : [ "url" : "http://www.example.com/avatar/1", "size" : "large"]],
        [ "id" : 2, "name" : "User 2" ],
        [ "id" : 3, "name" : "User 3" ],
        [ "id" : 4 ],
      ] as [[String : Any]],
    ],
  ]
  
  func testBasicDrilling() {
    let query: JSONQuery = [
      DictionarySubscriptQueryComponent(key: "response"),
      DictionarySubscriptQueryComponent(key: "status_code"),
    ]
    
    XCTAssertEqual(query.evaluate(on: exampleJSON) as! Int, 200)
  }
  
  func testDrillingAndMapping() {
    let query: JSONQuery = [
      DictionarySubscriptQueryComponent(key: "response"),
      DictionarySubscriptQueryComponent(key: "users"),
      ArrayFlatMapFunctionQueryComponent(transform: [
        DictionarySubscriptQueryComponent(key: "avatar"),
        DictionarySubscriptQueryComponent(key: "size")
      ]),
    ]
    XCTAssertEqual(query.evaluate(on: exampleJSON) as! [String], ["large"])
  }
  
  func testDrilasdfasdfasdfasdflingAndMapping() {
    let query: JSONQuery = [
      DictionarySubscriptQueryComponent(key: "response"),
      DictionarySubscriptQueryComponent(key: "users"),
      ArrayFlatMapFunctionQueryComponent(transform: [
        DictionarySubscriptQueryComponent(key: "avatar"),
      ]),
      DictionarySubscriptQueryComponent(key: "zorp")
    ]
    XCTAssertNil(query.evaluate(on: exampleJSON))
  }
}
