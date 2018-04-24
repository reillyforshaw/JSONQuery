//
//  Parser.swift
//  JSONQuery
//
//  Created by Reilly Forshaw on 2018-03-30.
//  Copyright © 2018 Reilly Forshaw. All rights reserved.
//

import Foundation
import AcmeUnit

public class Parser {
  public enum Error: Swift.Error {
    case endOfInput(at: String.Index)
    case expectedQuotation(at: String.Index)
    case invalidEscapeSequence(at: String.Index)
    case unterminatedQuotedString(at: String.Index)
  }


  public let input: String
  private(set) public var cursor: String.Index

  public var isFinished: Bool { return cursor >= input.endIndex }
  public var charactersRemaining: Int { return input.distance(from: cursor, to: input.endIndex) }

  private init(input: String, cursor: String.Index) {
    self.input = input
    self.cursor = cursor
  }

  public convenience init(input: String) {
    self.init(input: input, cursor: input.startIndex)
  }

  public func peekCharacter(offsetBy offset: Int = 0) -> Character {
    return input[input.index(cursor, offsetBy: offset)]
  }

  public func take(string: String) -> Bool {
    guard charactersRemaining >= string.count else { return false }

    var currentInputCursor = cursor
    var currentStringCursor = string.startIndex

    while currentStringCursor < string.endIndex {
      if string[currentStringCursor] != input[currentInputCursor] {
        return false
      }

      currentInputCursor = input.index(after: currentInputCursor)
      currentStringCursor = string.index(after: currentStringCursor)
    }

    cursor = currentInputCursor

    return true;
  }

  public func take(until predicate: (Character) -> Bool) throws -> String {
    var characters: [Character] = []

    while !isFinished {
      if predicate(peekCharacter()) {
        return String(characters)
      }
      characters.append(peekCharacter())
      advance()
    }

    throw Error.endOfInput(at: cursor)
  }

  public func takeUntilEndOfInput(or predicate: (Character) -> Bool) -> String {
    var characters: [Character] = []
    while !isFinished && !predicate(peekCharacter()) {
      characters.append(peekCharacter())
      advance()
    }

    return String(characters)
  }

  public func takeQuotedString() throws -> String {
    guard !isFinished else { throw Error.endOfInput(at: cursor) }
    guard peekCharacter() == "\"" else { throw Error.expectedQuotation(at: cursor) }
    advance()

    var characters: [Character] = []
    var escaping = false
    while !isFinished {
      defer {
        advance()
      }
      if peekCharacter() == "\\" {
        if escaping {
          characters.append("\\")
        }
        escaping = !escaping
        continue
      }

      switch (peekCharacter(), escaping) {
      case ("\"", false):
        return String(characters)
      case ("\"", true):
        characters.append("\"")
      case (_, true):
        throw Error.invalidEscapeSequence(at: cursor)
      default:
        characters.append(peekCharacter())
      }
      escaping = false
    }
    throw Error.unterminatedQuotedString(at: cursor)
  }

  private func advance(by offset: UInt = 1) {
    cursor = input.index(cursor, offsetBy: Int(offset))
  }
}

