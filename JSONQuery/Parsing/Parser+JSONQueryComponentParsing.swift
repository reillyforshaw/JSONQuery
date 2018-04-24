//
//  Parser+JSONQueryComponentParsing.swift
//  JSONQuery
//
//  Created by Reilly Forshaw on 2018-04-23.
//  Copyright © 2018 Reilly Forshaw. All rights reserved.
//

import Foundation

extension Parser {
  public enum QueryComponentParseError: Swift.Error {
    case expectedComponentDelimiter(at: String.Index)
    case expectedLeftBracket(at: String.Index)
    case expectedRightBracket(at: String.Index)
    case expectedQueryComponent(at: String.Index)
    case unknownFunction(name: String, at: String.Index)
  }

  public static let disallowedUnquotedDictionarySubscriptCharacters: Set<Character> = [".", "(", ")"]

  public func parseQuery(withSentinel sentinel: Character? = nil) throws -> JSONQuery {
    var query: JSONQuery = []

    var terminate: Bool {
      return sentinel.map {
        isFinished || peekCharacter() == $0
      } ?? isFinished
    }

    while !terminate {
      if !query.isEmpty {
        guard take(string: ".") else {
          throw QueryComponentParseError.expectedComponentDelimiter(at: cursor)
        }
      }

      query.append(try parseComponent())
    }

    return query
  }

  private func parseComponent() throws -> JSONQueryComponent {
    let parserFunc = try nextViableParseFunc()
    return try parserFunc()
  }

  private func parseArraySubscriptQueryComponent() throws -> ArraySubscriptQueryComponent {
    let number = takeUntilEndOfInput(or: { $0 < "0" || $0 > "9" })
    guard !number.isEmpty else {
      throw QueryComponentParseError.expectedQueryComponent(at: cursor)
    }

    return ArraySubscriptQueryComponent(index: Int(number)!)
  }

  private func parseDictionaryUnquotedSubscriptQueryComponent() throws -> DictionarySubscriptQueryComponent {
    let key = takeUntilEndOfInput(or: { Parser.disallowedUnquotedDictionarySubscriptCharacters.contains($0) })
    guard !key.isEmpty else {
      throw QueryComponentParseError.expectedQueryComponent(at: cursor)
    }

    return DictionarySubscriptQueryComponent(key: key)
  }

  private func parseFunctionComponent() throws -> JSONQueryComponent {
    guard take(string: "@") else {
      throw QueryComponentParseError.expectedQueryComponent(at: cursor)
    }

    return try parseFunctionNameAndArgumentList()
  }

  private func parseFunctionNameAndArgumentList() throws -> JSONQueryComponent {
    let functionNameStartCursor = cursor
    let functionName = try take(until: { $0 == "(" })

    guard take(string: "(") else {
      throw QueryComponentParseError.expectedLeftBracket(at: cursor)
    }

    let component: JSONQueryComponent
    switch functionName {
    case "flatMap":
      component = ArrayFlatMapFunctionQueryComponent(transform: try parseQuery(withSentinel: ")"))
    case "keys":
      component = DictionaryKeysFunctionQueryComponent()
    case "values":
      component = DictionaryValuesFunctionQueryComponent()
    default:
      throw QueryComponentParseError.unknownFunction(name: functionName, at: functionNameStartCursor)
    }

    guard take(string: ")") else {
      throw QueryComponentParseError.expectedRightBracket(at: cursor)
    }

    return component
  }

  private func parseDictionaryQuotedSubscriptQueryComponent() throws -> DictionarySubscriptQueryComponent {
    let string = try takeQuotedString()
    return DictionarySubscriptQueryComponent(key: string)
  }

  private func nextViableParseFunc() throws -> (() throws -> JSONQueryComponent) {
    guard !isFinished else {
      throw QueryComponentParseError.expectedQueryComponent(at: cursor)
    }
    switch peekCharacter() {
    case "@":
      return parseFunctionComponent
    case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
      return parseArraySubscriptQueryComponent
    case "\"":
      return parseDictionaryQuotedSubscriptQueryComponent
    default:
      return parseDictionaryUnquotedSubscriptQueryComponent
    }
  }
}
