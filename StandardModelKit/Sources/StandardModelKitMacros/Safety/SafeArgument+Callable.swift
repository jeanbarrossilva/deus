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

/// ``SafeArgument`` of a call to a function or an enum case with associated values.
public struct SafeCallableArgument<Parameter: SafeArgument>: SafeArgument, Identifiable {
  public var description: String { "\(id)(\(parameters.map(\.description).joined()))" }
  public private(set) var syntax: FunctionCallExprSyntax?
  public let id: String

  /// ``SafeArgument``-conformant parameters passed into the callable.
  public let parameters: [Parameter]

  public init(id: String, parameters: [Parameter] = []) {
    self.id = id
    self.parameters = parameters
  }

  public static func _make(
    from syntax: FunctionCallExprSyntax
  ) throws -> SafeCallableArgument<Parameter> {
    var argument = Self.init(
      id: _extractValue(
        from: try expect(syntax.calledExpression, toBeOfType: MemberAccessExprSyntax.self)
      ),
      parameters: try SafeDirectCollectionArgument<LabeledExprListSyntax, Parameter>._make(
        from: syntax.arguments
      )._delegate
    )
    argument.syntax = syntax
    return argument
  }
}

extension SafeCallableArgument: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id && lhs.parameters == rhs.parameters
  }
}

extension SafeCallableArgument: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) { self = .init(id: value, parameters: []) }
}

/// Makes a callable argument from a `FunctionCallExprSyntax`.
///
/// - Parameters:
///   - syntax: Syntax from which a ``SafeCallableArgument`` will be initialized.
///   - parameterType: Type of the parameters of the callable.
/// - Throws: If the called expression is not an access to a member or the arguments cannot be
///   converted into an argument of the specified type.
public func safe<Parameter: SafeArgument>(
  _ syntax: FunctionCallExprSyntax,
  parameterizedWith parameterType: Parameter.Type,
) throws -> SafeCallableArgument<Parameter> { try ._make(from: syntax) }
