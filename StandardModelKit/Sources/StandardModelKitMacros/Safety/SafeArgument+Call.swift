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

// MARK: - Typed calls

/// ``SafeArgument`` of a call to a function or an enum case with associated values.
public struct SafeCallArgument<Parameter: SafeArgument>: SafeCallArgumentProtocol {
  public let id: String
  public private(set) var syntax: FunctionCallExprSyntax?
  public let typeErasedParameters: [AnySafeArgument]

  /// Typed ``SafeArgument``-conformant parameters passed into the callable.
  public let typedParameters: [Parameter]

  public init(id: String, parameters: [Parameter] = []) {
    self.id = id
    typeErasedParameters = parameters.map { parameter in AnySafeArgument(parameter) }
    typedParameters = parameters
  }

  public static func _make(from syntax: FunctionCallExprSyntax) throws -> Self {
    var argument = Self.init(
      id: try _extractID(from: syntax),
      parameters: try safe(elementsFrom: syntax.arguments)
    )
    argument.syntax = syntax
    return argument
  }
}

extension SafeCallArgument: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) { self = .init(id: value, parameters: []) }
}

/// Makes a call argument from a `FunctionCallExprSyntax`.
///
/// - Parameters:
///   - syntax: Syntax from which a ``SafeCallableArgument`` will be initialized.
///   - parameterType: Type of the parameters of the callable.
/// - Throws: If the called expression is not an access to a member or the arguments cannot be
///   converted into an argument of the specified type.
public func safe<Parameter: SafeArgument>(
  _ syntax: FunctionCallExprSyntax,
  parameterizedWith parameterType: Parameter.Type,
) throws -> SafeCallArgument<Parameter> { try ._make(from: syntax) }

// MARK: - Type-erased calls

/// ``SafeArgument`` of a call to a function or an enum case with associated values whose parameters
/// are type-erased.
public struct SafeCallWithTypeErasedParametersArgument: SafeCallArgumentProtocol {
  public let id: String
  public private(set) var syntax: FunctionCallExprSyntax?
  public let typeErasedParameters: [AnySafeArgument]

  public init(id: String, parameters: [AnySafeArgument]) {
    self.id = id
    typeErasedParameters = parameters
  }

  public static func _make(from syntax: FunctionCallExprSyntax) throws -> Self {
    var argument = Self.init(
      id: try _extractID(from: syntax),
      parameters: try safe(elementsFrom: syntax.arguments)
    )
    argument.syntax = syntax
    return argument
  }
}

extension SafeCallWithTypeErasedParametersArgument: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) { self = .init(id: value, parameters: []) }
}

/// Makes a call argument whose parameters are type-erased from a `FunctionCallExprSyntax`.
///
/// - Parameters:
///   - syntax: Syntax from which a ``SafeCallableArgument`` will be initialized.
/// - Throws: If the called expression is not an access to a member.
public func safe(
  _ syntax: FunctionCallExprSyntax
) throws -> SafeCallWithTypeErasedParametersArgument { try ._make(from: syntax) }

// MARK: - Call basis

/// Base protocol to which ``SafeCallArgument`` and ``SafeCallWithTypedErasedParametersArgument``
/// conform.
public protocol SafeCallArgumentProtocol: ExpressibleByStringLiteral, Identifiable, SafeArgument {
  var id: String { get }
  var syntax: FunctionCallExprSyntax? { get }

  /// Type-erased ``SafeArgument``-conformant parameters passed into the callable.
  var typeErasedParameters: [AnySafeArgument] { get }
}

extension SafeCallArgumentProtocol where Self: CustomDebugStringConvertible {
  public var debugDescription: String {
    "\(id)(\(typeErasedParameters.map(\.debugDescription).joined())"
  }
}

extension SafeCallArgumentProtocol where Self: CustomStringConvertible {
  public var description: String { "\(id)(\(typeErasedParameters.map(\.description).joined()))" }
}

extension SafeCallArgumentProtocol where Self: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id && lhs.typeErasedParameters == rhs.typeErasedParameters
  }
}

/// Extracts the ID of a ``SafeCallArgument`` from a `FunctionCallExprSyntax.`
///
/// - Parameter syntax: Call to a function whose called expression is that whose identifier will be
///   extracted.
private func _extractID(from syntax: FunctionCallExprSyntax) throws(DiagnosticsError) -> String {
  _extractID(from: try expect(syntax.calledExpression, toBeOfType: MemberAccessExprSyntax.self))
}
