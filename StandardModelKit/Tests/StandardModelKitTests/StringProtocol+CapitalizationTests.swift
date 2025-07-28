// ===-------------------------------------------------------------------------------------------===
// Copyright © 2025 Deus
//
// This file is part of the Deus open-source project.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
// even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If
// not, see https://www.gnu.org/licenses.
// ===-------------------------------------------------------------------------------------------===

import StandardModelKitMacros
import XCTest

final class ReplacementWithCapitalizationTests: XCTestCase {
  func testReturnOfSelfWhenMaxReplacementCountIsZeroOrLess() throws {
    let unreplaced = "Hello, world!"
    for maxReplacementCount in Int(-1)...0 {
      let replaced = try unreplaced.replacingWithCapitalization(
        #/Hello/#,
        by: "Goodbye",
        maxReplacements: maxReplacementCount
      )
      XCTAssertEqual(
        replaced,
        unreplaced,
        "\"\(replaced)\" was returned instead of \"\(unreplaced)\" with a `maxReplacementCount` of "
          + "\(maxReplacementCount)."
      )
    }
  }

  func testReturnOfSelfWhenReplacingSubstringsByThemselves() {
    XCTAssertEqual(
      try "Hello, world!".replacingWithCapitalization(#/world/#, by: "world"),
      "Hello, world!"
    )
  }

  func testOneReplacementOfOneOccurence() {
    XCTAssertEqual(
      try "helloSavannah".replacingWithCapitalization(
        #/Savannah/#,
        by: "world",
        maxReplacements: 1
      ),
      "helloWorld"
    )
  }

  func testOneReplacementOfManyOccurences() {
    XCTAssertEqual(
      try "helloWorldBrown".replacingWithCapitalization(
        #/World|Brown/#,
        by: "Savannah",
        maxReplacements: 1
      ),
      "helloSavannahBrown"
    )
  }

  func testManyReplacementsOfManyOccurences() {
    XCTAssertEqual(
      try "Hello, world...".replacingWithCapitalization(#/\.{3}/#, by: "!!!"),
      "Hello, world!!!"
    )
  }
}
