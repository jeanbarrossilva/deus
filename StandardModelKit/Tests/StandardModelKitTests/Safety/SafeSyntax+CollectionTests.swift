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

import MacroToolkit
import StandardModelKitMacros
import SwiftDiagnostics
import SwiftSyntax
import XCTest

final class SafeIndirectArraySyntaxTests: XCTestCase {
  func
    testThrowingWhenInitializingFromSyntaxWithCollectionWhoseElementsAreInequivalentToTheSpecifiedType()
  {
    XCTAssertThrowsError(
      try safe(
        ArrayExprSyntax(
          elements: ArrayElementListSyntax(expressions: [
            ExprSyntax(IntegerLiteralExprSyntax(integerLiteral: 2)),
            ExprSyntax(IntegerLiteralExprSyntax(integerLiteral: 4))
          ])
        ),
        containing: SafeString.self
      )
    ) { (error: DiagnosticsError) in
      let diagnosticCount = error.diagnostics.count
      XCTAssertEqual(diagnosticCount, 1, "Expected a single diagnostic; got \(diagnosticCount).")
      let diagnostic = error.diagnostics[0]
      XCTAssertEqual(diagnostic.diagnosticID, _nodeTypeMismatchDiagnosticID)
      XCTAssertEqual(
        diagnostic.message,
        "Expected IntegerLiteralExprSyntax `2` to be of type StringLiteralExprSyntax"
      )
    }
  }

  func testInitializationFromSyntax() throws {
    XCTAssertEqual(
      try safe(
        ArrayExprSyntax(
          elements: ArrayElementListSyntax(expressions: [
            ExprSyntax(StringLiteralExprSyntax(content: "Hello, ")),
            ExprSyntax(StringLiteralExprSyntax(content: "world!"))
          ])
        ),
        containing: SafeString.self
      ),
      ["Hello, ", "world!"]
    )
  }
}

final class SafeDirectCollectionSyntaxTests: XCTestCase {
  func testThrowingWhenInitializingFromSyntaxWhoseElementsAreInequevalentToTheSpecifiedType() {
    XCTAssertThrowsError(
      try safe(
        ArrayElementListSyntax(expressions: [
          ExprSyntax(IntegerLiteralExprSyntax(integerLiteral: 2)),
          ExprSyntax(IntegerLiteralExprSyntax(integerLiteral: 4))
        ]),
        containing: SafeString.self
      )
    ) { (error: DiagnosticsError) in
      let diagnosticCount = error.diagnostics.count
      XCTAssertEqual(diagnosticCount, 1, "Expected a single diagnostic; got \(diagnosticCount).")
      let diagnostic = error.diagnostics[0]
      XCTAssertEqual(diagnostic.diagnosticID, _nodeTypeMismatchDiagnosticID)
      XCTAssertEqual(
        diagnostic.message,
        "Expected IntegerLiteralExprSyntax `2` to be of type StringLiteralExprSyntax"
      )
    }
  }

  func testInitializationFromSyntax() throws {
    XCTAssertEqual(
      try safe(
        ArrayElementListSyntax(expressions: [
          ExprSyntax(StringLiteralExprSyntax(content: "Hello, ")),
          ExprSyntax(StringLiteralExprSyntax(content: "world!"))
        ]),
        containing: SafeString.self
      ),
      ["Hello, ", "world!"]
    )
  }
}
