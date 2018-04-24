//
//  Parser+JSONQueryComponentParsingTests.swift
//  JSONQueryTests
//
//  Created by Reilly Forshaw on 2018-03-30.
//  Copyright © 2018 Reilly Forshaw. All rights reserved.
//

import Foundation
import XCTest

@testable import JSONQuery

private extension String {
  func startIndex(offsetBy offset: Int) -> String.Index {
    return index(startIndex, offsetBy: offset)
  }
}

class Parser_JSONQueryComponentParsingTests : XCTestCase {
  // MARK: Trivial Query Tests

  func testEmptyInput() {
    let parser = Parser(input: "")

    XCTAssertTrue(try! parser.parseQuery().isEmpty)
  }

  func testQuery() {
    let parser = Parser(input: "foo.42.baz.@keys()")
    let query = try! parser.parseQuery()
    XCTAssertEqual(query.count, 4)
    XCTAssertEqual((query[0] as! DictionarySubscriptQueryComponent).key, "foo")
    XCTAssertEqual((query[1] as! ArraySubscriptQueryComponent).index, 42)
    XCTAssertEqual((query[2] as! DictionarySubscriptQueryComponent).key, "baz")
    XCTAssertNotNil((query[3] as? DictionaryKeysFunctionQueryComponent))
  }

  // MARK: Delimiter Error Tests

  func testLeadingDelimiterIsError() {
    let input = ".foo"
    let parser = Parser(input: input)

    do {
      _ = try parser.parseQuery()
      XCTFail("Expected an error")
    } catch let Parser.QueryComponentParseError.expectedQueryComponent(location) {
      XCTAssertEqual(location, input.startIndex)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testTrailingDelimiterIsError() {
    let input = "foo."
    let parser = Parser(input: input)

    do {
      _ = try parser.parseQuery()
      XCTFail("Expected an error")
    } catch let Parser.QueryComponentParseError.expectedQueryComponent(location) {
      XCTAssertEqual(location, input.startIndex(offsetBy: 4))
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  // MARK: Array Index Tests

  func testNumericInputResultsInArraySubscript() {
    let parser = Parser(input: "123")
    let comp = try! parser.parseQuery()[0] as! ArraySubscriptQueryComponent

    XCTAssertEqual(comp.index, 123)
  }

  func testNumericFollowedByAlphabetIsExpectedDelimiterError() {
    let input = "123abc"
    let parser = Parser(input: input)

    do {
      _ = try parser.parseQuery()
      XCTFail("Expected an error")
    } catch let Parser.QueryComponentParseError.expectedComponentDelimiter(location) {
      XCTAssertEqual(location, input.startIndex(offsetBy: 3))
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  // MARK: Dictionary Key Tests

  func testLeadingNegativeCorrespondsToDictionarySubscript() {
    let parser = Parser(input: "-")
    let comp = try! parser.parseQuery()[0] as! DictionarySubscriptQueryComponent

    XCTAssertEqual(comp.key, "-")
  }

  func testKeysCanHaveEverythingExceptDisallowedCharacters() {
    let input = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ`1234567890-=~!@#$%^&*()_+[]\\{}|;':\",./<>?".filter {
      !Parser.disallowedUnquotedDictionarySubscriptCharacters.contains($0)
    }
    let parser = Parser(input: input)
    let comp = try! parser.parseQuery()[0] as! DictionarySubscriptQueryComponent
    XCTAssertEqual(comp.key, input)
  }

  func testQuotedKeysCanHaveEverythingIncludingEscapedQuotesAndEscapedEscapes() {
    let input = "\"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ`1234567890-=~!@#$%^&*()_+[]\\\\{}|;':\\\",./<>?\""
    let parser = Parser(input: input)
    let comp = try! parser.parseQuery()[0] as! DictionarySubscriptQueryComponent
    XCTAssertEqual(comp.key, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ`1234567890-=~!@#$%^&*()_+[]\\{}|;':\",./<>?")
  }

  // MARK: Function Tests

  func testUnknownFunctionThrowsError() {
    let input = "@foo()"
    let parser = Parser(input: input)

    do {
      _ = try parser.parseQuery()
      XCTFail("Expected an error")
    } catch let Parser.QueryComponentParseError.unknownFunction(name, location) {
      XCTAssertEqual(name, "foo")
      XCTAssertEqual(location, input.startIndex(offsetBy: 1))
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testFunctionNotFollowedByLeftBracket() {
    let input = "@keys"
    let parser = Parser(input: input)

    do {
      _ = try parser.parseQuery()
      XCTFail("Expected an error")
    } catch let Parser.Error.endOfInput(location) {
      // TODO improve error here
      XCTAssertEqual(location, input.startIndex(offsetBy: 5))
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testFunctionNotFollowedByRightBracket() {
    let input = "@keys("
    let parser = Parser(input: input)

    do {
      _ = try parser.parseQuery()
      XCTFail("Expected an error")
    } catch let Parser.QueryComponentParseError.expectedRightBracket(location) {
      // TODO improve error here
      XCTAssertEqual(location, input.startIndex(offsetBy: 6))
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testArrayFlatMapWithNoArguments() {
    let parser = Parser(input: "@flatMap()")
    let comp = try! parser.parseQuery()[0] as! ArrayFlatMapFunctionQueryComponent

    XCTAssertTrue(comp.transform.isEmpty)
  }

  func testArrayFlatMapWithSubComponents() {
    let parser = Parser(input: "@flatMap(foo.bar)")
    let comp = try! parser.parseQuery()[0] as! ArrayFlatMapFunctionQueryComponent
    let keys = comp.transform.map { ($0 as? DictionarySubscriptQueryComponent)!.key }

    XCTAssertEqual(keys, ["foo", "bar"])
  }

  func testDictionaryKeysWithNoArguments() {
    let parser = Parser(input: "@keys()")
    let comp = try! parser.parseQuery()[0] as? DictionaryKeysFunctionQueryComponent

    XCTAssertNotNil(comp)
  }

  func testDictionaryKeysWithArguments() {
    let input = "@keys(foo)"
    let parser = Parser(input: input)

    do {
      _ = try parser.parseQuery()
      XCTFail("Expected an error")
    } catch let Parser.QueryComponentParseError.expectedRightBracket(location) {
      // TODO improve error here
      XCTAssertEqual(location, input.startIndex(offsetBy: 6))
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testDictionaryValuesWithNoArguments() {
    let parser = Parser(input: "@values()")
    let comp = try! parser.parseQuery()[0] as? DictionaryValuesFunctionQueryComponent

    XCTAssertNotNil(comp)
  }

  func testDictionaryValuesWithArguments() {
    let input = "@values(foo)"
    let parser = Parser(input: input)

    do {
      _ = try parser.parseQuery()
      XCTFail("Expected an error")
    } catch let Parser.QueryComponentParseError.expectedRightBracket(location) {
      // TODO improve error here
      XCTAssertEqual(location, input.startIndex(offsetBy: 8))
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
}
