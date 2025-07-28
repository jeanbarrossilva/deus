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

// MARK: - Type erasure

/// Type-erased ``SafeArgument``.
public struct AnySafeArgument: SafeArgument {
  /// ``Hashable`` to which conformance to such type is delegated.
  private let _hashableDelegate: any Hashable

  public private(set) var debugDescription: String
  public private(set) var description: String
  public let syntax: Syntax?

  /// ``SafeArgument`` type-erased by this wrapper, or `nil` in case this wrapper was initialized
  /// from a syntax. When this `AnyHashable` is present, force-casting its own base value to the
  /// original type is a safe operation.
  public let base: AnyHashable?

  init(_ base: some SafeArgument) {
    _hashableDelegate = base
    debugDescription = base.debugDescription
    description = base.description
    syntax = nil
    self.base = AnyHashable(base)
  }

  init(_ base: any SafeArgument) {
    _hashableDelegate = base
    debugDescription = base.debugDescription
    description = base.description
    syntax = nil
    self.base = nil
  }

  private init(from syntax: Syntax) {
    _hashableDelegate = syntax
    debugDescription = syntax.debugDescription
    description = syntax.description
    self.syntax = syntax
    base = nil
  }

  public static func _make(from syntax: Syntax) throws -> Self { .init(from: syntax) }
}

extension AnySafeArgument: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.base == rhs.base || lhs.syntax == rhs.syntax || lhs.hashValue == rhs.hashValue
  }
}

extension AnySafeArgument: Hashable {
  public var hashValue: Int { _hashableDelegate.hashValue }

  public func hash(into hasher: inout Hasher) { _hashableDelegate.hash(into: &hasher) }
}

/// Makes a type-erased ``SafeArgument`` from a type-erased syntax from `SwiftSyntax`.
///
/// - Parameter syntax: Syntax from which the ``SafeArgument`` will be made.
/// - Throws:
///   - If the `syntax` is a `FunctionCallExprSyntax` and the called expression is not an access to
///     a member; or
///   - if the `syntax` is a `IntegerLiteralExprSyntax` and the literal is not an integer; or
///   - if the `syntax` is a `StringLiteralExprSyntax` and the string cannot be evaluated.
public func safe(_ syntax: any SyntaxProtocol) throws -> any SafeArgument {
  return if let syntax = syntax.as(SafeCallWithTypeErasedParametersArgument.Syntax.self) {
    try SafeCallWithTypeErasedParametersArgument._make(from: syntax)
  } else if let syntax = syntax.as(SafeIndirectArrayWithTypeErasedElementsArgument.Syntax.self) {
    try SafeIndirectArrayWithTypeErasedElementsArgument._make(from: syntax)
  } else if let syntax = syntax.as(SafeIntArgument.Syntax.self) {
    try SafeIntArgument._make(from: syntax)
  } else if let syntax = syntax.as(SafePropertyArgument.Syntax.self) {
    try SafePropertyArgument._make(from: syntax)
  } else if let syntax = syntax.as(SafeStringArgument.Syntax.self) {
    try SafeStringArgument._make(from: syntax)
  } // ===- Direct collections ------------------------------------------------------------------===
  else if let syntax = syntax.as(ArrayElementListSyntax.self) {
    try SafeDirectCollectionWithTypeErasedElementsArgument._make(from: syntax)
  } else if let syntax = syntax.as(LabeledExprListSyntax.self) {
    try SafeDirectCollectionWithTypeErasedElementsArgument._make(from: syntax)
  } else { try AnySafeArgument._make(from: syntax as? Syntax ?? Syntax(syntax)) }
}

// MARK: - Declaration

/// Type-safe, compile-time argument passed into a macro.
public protocol SafeArgument<Syntax>: CustomDebugStringConvertible, CustomStringConvertible,
  Equatable, Hashable
{
  /// `SwiftSyntax` type equivalent to this type of argument.
  associatedtype Syntax: SyntaxProtocol

  /// Syntax from which this argument was initialized or `nil` in case it was not initialized from a
  /// syntax, but, rather, directly.
  var syntax: Syntax? { get }

  /// Makes an argument of this type from the `syntax`.
  ///
  /// > Note: the ``syntax`` property **should** have been assigned to by the time this function
  /// returns.
  ///
  /// - Parameter syntax: `SwiftSyntax` syntax from which this type of argument will be
  ///   initialized.
  static func _make(from syntax: Syntax) throws -> Self
}
