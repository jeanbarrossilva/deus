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

final class SafeArgumentIntTests: XCTestCase {
  func testThrowingWhenSyntaxContainsNonIntegerLiteral() {
    XCTAssertThrowsError(try safe(IntegerLiteralExprSyntax(literal: "Hello, world!"))) {
      (error: DiagnosticsError) in
      let diagnosticCount = error.diagnostics.count
      XCTAssertEqual(diagnosticCount, 1, "Expected a single diagnostic; got \(diagnosticCount).")
      let diagnostic = error.diagnostics[0]
      XCTAssertEqual(diagnostic.diagnosticID, SafeIntArgument._nonIntegerLiteralDiagnosticID)
      XCTAssertEqual(diagnostic.message, "identifier(\"Hello, world!\") is not an integer")
    }
  }

  func testInitializationFromSyntax() {
    XCTAssertEqual(
      try safe(
        IntegerLiteralExprSyntax(literal: TokenSyntax(.integerLiteral("2"), presence: .present))
      ),
      2
    )
  }
}
