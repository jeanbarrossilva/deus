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
import SwiftDiagnostics
import SwiftSyntax
import XCTest

final class SafeSyntaxCallTests: XCTestCase {
  func testThrowingWhenCalledExpressionIsNotAMemberAccess() {
    XCTAssertThrowsError(
      try safe(
        FunctionCallExprSyntax(
          calledExpression: StringLiteralExprSyntax(content: "Hello, world!"),
          arguments: LabeledExprListSyntax([])
        ),
        parameterizedWith: SafeString.self
      )
    ) { (error: DiagnosticsError) in
      let diagnosticCount = error.diagnostics.count
      XCTAssertEqual(diagnosticCount, 1, "Expected a single diagnostic; got \(diagnosticCount).")
      let diagnostic = error.diagnostics[0]
      XCTAssertEqual(diagnostic.diagnosticID, _nodeTypeMismatchDiagnosticID)
      XCTAssertEqual(
        diagnostic.message,
        "Expected StringLiteralExprSyntax \"Hello, world!\" to be of type MemberAccessExprSyntax"
      )
    }
  }

  func testInitializationWithoutAssociatedValuesFromSyntax() {
    XCTAssertEqual(
      try safe(
        FunctionCallExprSyntax(
          calledExpression: MemberAccessExprSyntax(
            declName: DeclReferenceExprSyntax(baseName: "hello")
          ),
          arguments: LabeledExprListSyntax([])
        ),
        parameterizedWith: SafeString.self
      ),
      "hello"
    )
  }

  func testInitializationWithAssociatedValuesFromSyntax() {
    XCTAssertEqual(
      try safe(
        FunctionCallExprSyntax(
          calledExpression: MemberAccessExprSyntax(
            declName: DeclReferenceExprSyntax(baseName: "hello")
          ),
          arguments: LabeledExprListSyntax([
            LabeledExprSyntax(expression: StringLiteralExprSyntax(content: "world"))
          ])
        ),
        parameterizedWith: SafeString.self
      ),
      SafeCall<SafeString>(id: "hello", parameters: ["world"])
    )
  }
}
