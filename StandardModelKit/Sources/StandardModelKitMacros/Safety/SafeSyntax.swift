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

/// Type-erased ``SafeSyntax``.
public struct AnySafeSyntax: SafeSyntax {
  /// ``Hashable`` to which conformance to such type is delegated.
  private let _hashableDelegate: any Hashable

  public private(set) var debugDescription: String
  public private(set) var description: String
  public let node: Syntax?

  /// ``SafeSyntax`` type-erased by this wrapper, or `nil` in case this wrapper was initialized from
  /// a node. When this `AnyHashable` is present, force-casting its own base value to the original
  /// type is a safe operation.
  public let base: AnyHashable?

  init(_ base: some SafeSyntax) {
    _hashableDelegate = base
    debugDescription = base.debugDescription
    description = base.description
    node = nil
    self.base = AnyHashable(base)
  }

  init(_ base: any SafeSyntax) {
    _hashableDelegate = base
    debugDescription = base.debugDescription
    description = base.description
    node = nil
    self.base = nil
  }

  private init(from node: Syntax) {
    _hashableDelegate = node
    debugDescription = node.debugDescription
    description = node.description
    self.node = node
    base = nil
  }

  public static func _make(from node: Syntax) throws -> Self { .init(from: node) }
}

extension AnySafeSyntax: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.base == rhs.base || lhs.node == rhs.node || lhs.hashValue == rhs.hashValue
  }
}

extension AnySafeSyntax: Hashable {
  public var hashValue: Int { _hashableDelegate.hashValue }

  public func hash(into hasher: inout Hasher) { _hashableDelegate.hash(into: &hasher) }
}

/// Makes a type-erased ``SafeSyntax`` from a type-erased node from `SwiftSyntax`.
///
/// - Parameter node: Node from which the ``SafeSyntax`` will be made.
/// - Throws:
///   - If the `node` is a `FunctionCallExprSyntax` and the called expression is not an access to a
///     member; or
///   - if the `node` is a `IntegerLiteralExprSyntax` and the literal is not an integer; or
///   - if the `node` is a `StringLiteralExprSyntax` and the string cannot be evaluated.
public func safe(_ node: any SyntaxProtocol) throws -> any SafeSyntax {
  return if let node = node.as(SafeCallWithTypeErasedParameters.Node.self) {
    try SafeCallWithTypeErasedParameters._make(from: node)
  } else if let node = node.as(SafeIndirectArrayWithTypeErasedElements.Node.self) {
    try SafeIndirectArrayWithTypeErasedElements._make(from: node)
  } else if let node = node.as(SafeInt.Node.self) {
    try SafeInt._make(from: node)
  } else if let node = node.as(SafeProperty.Node.self) {
    try SafeProperty._make(from: node)
  } else if let node = node.as(SafeString.Node.self) { try SafeString._make(from: node) }
  // ===- Direct collections --------------------------------------------------------------------===
  else if let node = node.as(ArrayElementListSyntax.self) {
    try SafeDirectCollectionWithTypeErasedElements._make(from: node)
  } else if let node = node.as(LabeledExprListSyntax.self) {
    try SafeDirectCollectionWithTypeErasedElements._make(from: node)
  } else { try AnySafeSyntax._make(from: node as? Syntax ?? Syntax(node)) }
}

// MARK: - Declaration

/// Type-safe, compile-time value passed into a macro.
public protocol SafeSyntax<Node>: CustomDebugStringConvertible, CustomStringConvertible, Equatable,
  Hashable
{
  /// `SwiftSyntax` type equivalent to this ``SafeSyntax``.
  associatedtype Node: SyntaxProtocol

  /// Node from which this ``SafeSyntax`` was initialized or `nil` in case it was not initialized
  /// from a node, but, rather, directly.
  var node: Node? { get }

  /// Makes a ``SafeSyntax`` of this type from the `node`.
  ///
  /// > Note: the ``node`` property **should** have been assigned to by the time this function
  ///   returns.
  ///
  /// - Parameter node: `SwiftSyntax` node from which this type of ``SafeSyntax`` will be
  ///   initialized.
  static func _make(from node: Node) throws -> Self
}
