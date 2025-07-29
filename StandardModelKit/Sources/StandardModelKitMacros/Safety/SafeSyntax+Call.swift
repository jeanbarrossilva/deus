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

/// ``SafeSyntax`` of a call to a function or an enum case with associated values.
public struct SafeCall<Parameter: SafeSyntax>: SafeCallArgumentProtocol {
  public let id: String
  public private(set) var node: FunctionCallExprSyntax?
  public let typeErasedParameters: [AnySafeSyntax]

  /// Typed ``SafeSyntax``-conformant parameters passed into the callable.
  public let typedParameters: [Parameter]

  public init(id: String, parameters: [Parameter] = []) {
    self.id = id
    typeErasedParameters = parameters.map { parameter in AnySafeSyntax(parameter) }
    typedParameters = parameters
  }

  public static func _make(from node: FunctionCallExprSyntax) throws -> Self {
    var safe = Self.init(
      id: try _extractID(from: node),
      parameters: try safe(elementsFrom: node.arguments)
    )
    safe.node = node
    return safe
  }
}

extension SafeCall: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) { self = .init(id: value, parameters: []) }
}

/// Makes a ``SafeCall`` from a `FunctionCallExprSyntax`.
///
/// - Parameters:
///   - node: Node from which a ``SafeCall`` will be initialized.
///   - parameterType: Type of the parameters of the callable.
/// - Throws: If the called expression is not an access to a member or the arguments cannot be
///   converted into an argument of the specified type.
public func safe<Parameter: SafeSyntax>(
  _ node: FunctionCallExprSyntax,
  parameterizedWith parameterType: Parameter.Type,
) throws -> SafeCall<Parameter> { try ._make(from: node) }

// MARK: - Type-erased calls

/// ``SafeSyntax`` of a call to a function or an enum case with associated values whose parameters
/// are type-erased.
public struct SafeCallWithTypeErasedParameters: SafeCallArgumentProtocol {
  public let id: String
  public private(set) var node: FunctionCallExprSyntax?
  public let typeErasedParameters: [AnySafeSyntax]

  public init(id: String, parameters: [AnySafeSyntax]) {
    self.id = id
    typeErasedParameters = parameters
  }

  public static func _make(from node: FunctionCallExprSyntax) throws -> Self {
    var safe = Self.init(
      id: try _extractID(from: node),
      parameters: try safe(elementsFrom: node.arguments)
    )
    safe.node = node
    return safe
  }
}

extension SafeCallWithTypeErasedParameters: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) { self = .init(id: value, parameters: []) }
}

/// Makes a call argument whose parameters are type-erased from a `FunctionCallExprSyntax`.
///
/// - Parameters:
///   - node: Node from which a ``SafeCall`` will be initialized.
/// - Throws: If the called expression is not an access to a member.
public func safe(_ node: FunctionCallExprSyntax) throws -> SafeCallWithTypeErasedParameters {
  try ._make(from: node)
}

// MARK: - Call basis

/// Base protocol to which ``SafeCall`` and ``SafeCallWithTypedErasedParameters`` conform.
public protocol SafeCallArgumentProtocol: ExpressibleByStringLiteral, Identifiable, SafeSyntax {
  var id: String { get }
  var node: FunctionCallExprSyntax? { get }

  /// Type-erased ``SafeSyntax``-conformant parameters passed into the callable.
  var typeErasedParameters: [AnySafeSyntax] { get }
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

/// Extracts the ID of a ``SafeCall`` from a `FunctionCallExprSyntax.`
///
/// - Parameter node: Call to a function whose called expression is that whose identifier will be
///   extracted.
private func _extractID(from node: FunctionCallExprSyntax) throws(DiagnosticsError) -> String {
  _extractID(from: try expect(node.calledExpression, toBeOfType: MemberAccessExprSyntax.self))
}
