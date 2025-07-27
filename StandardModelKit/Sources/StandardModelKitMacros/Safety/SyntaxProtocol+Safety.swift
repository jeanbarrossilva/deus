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
import SwiftDiagnostics
import SwiftSyntax

/// Identifier of a diagnostic about a missing syntax.
public let _missingSyntaxInCollectionDiagnosticID = MessageID(
  domain: "StandardModelKitMacros",
  id: "MissingSyntax"
)

/// Identifier of a diagnostic about a mismatch between the expected type of an element and that of
/// an actual one.
public let _syntaxTypeMismatchDiagnosticID = MessageID(
  domain: "StandardModelKitMacros",
  id: "ElementTypeMismatch"
)

/// Alternative to the casting functions provided by ``SwiftSyntax`` which differs from them in that
/// it throws a detailed error in case the given syntax, part of another one, is not of the expected
/// type. Alongside ``SafeArgument``s, reduces the boilerplate required for writing a macro.
///
/// - Parameters:
///   - actual: Syntax to be cast to the `expectedType`.
///   - parent: Syntax in which the `actual` one is contained.
///   - expectedType: Type which is expected to be that of the `actual` syntax.
/// - Returns: The `actual` syntax cast to the expected type or the `default` one in case it is
///   missing.
/// - Throws: If both `actual` and `default` syntaxes are missing or the type of the `actual` one is
///   not the expected one.
public func expect<Expected: SyntaxProtocol>(
  _ actual: (any SyntaxProtocol)?,
  in parent: (any SyntaxProtocol),
  toBeOfType expectedType: Expected.Type,
  defaultingTo default: Expected? = nil
) throws(DiagnosticsError) -> Expected {
  guard let syntax = actual ?? `default` else {
    throw DiagnosticsError(diagnostics: [
      Diagnostic(
        node: parent,
        message: SimpleDiagnosticMessage(
          message: "Expected a(n) \(expectedType) in \(parent)",
          diagnosticID: _missingSyntaxInCollectionDiagnosticID,
          severity: .error
        )
      )
    ])
  }
  guard let expected = syntax.as(expectedType) else {
    throw DiagnosticsError(diagnostics: [
      Diagnostic(
        node: syntax,
        message: SimpleDiagnosticMessage(
          message: "Expected \(syntax.syntaxNodeType) `\(syntax)` to be of type \(expectedType)",
          diagnosticID: _syntaxTypeMismatchDiagnosticID,
          severity: .error
        )
      )
    ])
  }
  return expected
}

/// Alternative to the casting functions provided by ``SwiftSyntax`` which differs from them in that
/// it throws a detailed error in case the given syntax is not of the expected type. Alongside
/// ``SafeArgument``s, reduces the boilerplate required for writing a macro.
///
/// - Parameters:
///   - actual: Syntax to be cast to the `expectedType`.
///   - expectedType: Type which is expected to be that of the given syntax.
/// - Returns: The syntax cast to the expected type.
/// - Throws: If the type of the syntax is not the expected one.
public func expect<Expected: SyntaxProtocol>(
  _ actual: any SyntaxProtocol,
  toBeOfType expectedType: Expected.Type
) throws(DiagnosticsError) -> Expected {
  guard let expected = actual.as(expectedType) else {
    throw DiagnosticsError(diagnostics: [
      Diagnostic(
        node: actual,
        message: SimpleDiagnosticMessage(
          message: "Expected \(actual.syntaxNodeType) \(actual) to be of type \(expectedType)",
          diagnosticID: _syntaxTypeMismatchDiagnosticID,
          severity: .error
        )
      )
    ])
  }
  return expected
}
