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

// MARK: - Indirect collections

/// ``SafeCollection`` which is based on an array expression containing a collection in which the
/// child nodes themselves are — hence its indirectness, aspect in which it differs from a
/// ``SafeDirectCollection``.
public struct SafeIndirectArray<Element: SafeSyntax>: SafeCollection {
  public let _delegate: [Element]
  public private(set) var node: ArrayExprSyntax?

  public init(arrayLiteral elements: Element...) { self = .init(delegate: elements) }

  private init(delegate: [Element]) { self._delegate = delegate }

  public static func _make(from node: ArrayExprSyntax) throws -> Self {
    var safe = Self.init(delegate: try safe(elementsFrom: node.elements))
    safe.node = node
    return safe
  }
}

/// ``SafeCollection`` whose elements are type-erased and which is based on an array expression
/// containing a collection in which the child nodes themselves are — hence its indirectness, aspect
/// in which it differs from a ``SafeDirectCollection``.
public struct SafeIndirectArrayWithTypeErasedElements: SafeCollection {
  public typealias Element = AnySafeSyntax

  public let _delegate: [AnySafeSyntax]
  public private(set) var node: ArrayExprSyntax?

  private init(delegate: [AnySafeSyntax]) { _delegate = delegate }

  public static func _make(from node: ArrayExprSyntax) throws -> Self {
    var safe = Self.init(delegate: try safe(elementsFrom: node.elements))
    safe.node = node
    return safe
  }
}

extension SafeIndirectArrayWithTypeErasedElements: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: AnySafeSyntax...) { self = .init(delegate: elements) }
}

/// Makes a ``SafeIndirectArray`` from an `ArrayExprSyntax`.
///
/// - Parameters:
///   - node: Node from which a ``SafeIndirectArray`` will be initialized.
///   - elementType: Type of the elements in the array.
/// - Throws: If one of the elements in the `SyntaxCollection` cannot be converted into an
///   `Element`.
public func safe<Element: SafeSyntax>(
  _ node: ArrayExprSyntax,
  containing elementType: Element.Type
) throws -> SafeIndirectArray<Element> { try ._make(from: node) }

/// Makes an indirect array ``SafeSyntax`` whose elements are type-erased from an `ArrayExprSyntax`.
///
/// - Parameters:
///   - node: Node from which a ``SafeIndirectArrayWithTypeErasedElements`` will be
///     initialized.
/// - Throws: Never.
public func safe(_ node: ArrayExprSyntax) throws -> SafeIndirectArrayWithTypeErasedElements {
  try ._make(from: node)
}

// MARK: - Direct collections

/// ``SafeCollection`` whose directness stems from its node itself being a collection
/// which is not within an expression — unlike that of a ``SafeIndirectArray``, which
/// *contains* a collection of nodes instead.
public struct SafeDirectCollection<Node: Equatable & SyntaxCollection, Element: SafeSyntax>:
  SafeCollection
{
  public let _delegate: [Element]
  public private(set) var node: Node?

  public init(arrayLiteral elements: Element...) { self = .init(elements) }

  private init(_ delegate: [Element]) { _delegate = delegate }

  public static func _make(from node: Node) throws -> Self {
    var safe = Self.init(try safe(elementsFrom: node))
    safe.node = node
    return safe
  }
}

/// ``SafeCollection`` whose elements are type-erased and directness stems from its syntax
/// itself being a collection which is not within an expression — unlike that of a
/// ``SafeIndirectArrayWithTypeErasedElements``, which *contains* a collection of nodes instead.
public struct SafeDirectCollectionWithTypeErasedElements<Node: Equatable & SyntaxCollection>:
  SafeCollection
{
  public typealias Element = AnySafeSyntax

  public let _delegate: [AnySafeSyntax]
  public private(set) var node: Node?

  public init(arrayLiteral elements: AnySafeSyntax...) { self = .init(elements) }

  init(_ delegate: [AnySafeSyntax]) { _delegate = delegate }

  public static func _make(from node: Node) throws -> Self {
    var safe = Self.init(try safe(elementsFrom: node))
    safe.node = node
    return safe
  }
}

/// Makes an direct collection ``SafeSyntax`` whose elements are type-erased from a
/// `SyntaxCollection`.
///
/// - Parameters:
///   - node: Node from which a ``SafeDirectCollectionWithTypeErasedElements`` will be
///     initialized.
/// - Throws: Never.
public func safe<Node: Equatable & SyntaxCollection>(
  _ node: Node
) throws -> SafeDirectCollectionWithTypeErasedElements<Node> { try ._make(from: node) }

/// Makes a ``SafeDirectCollection`` from an `ArrayElementListSyntax`.
///
/// - Parameters:
///   - node: Node from which a ``SafeDirectCollection`` will be initialized.
///   - elementType: Type of the elements in the collection.
/// - Throws: If one of the elements of the `node` cannot be converted into an `Element`.
public func safe<Element: SafeSyntax>(
  _ node: ArrayElementListSyntax,
  containing elementType: Element.Type
) throws -> SafeDirectCollection<ArrayElementListSyntax, Element> { try ._make(from: node) }

// MARK: - Collection basis

/// ``SafeSyntax`` which is a container of other ``SafeSyntax``s.
public protocol SafeCollection: BidirectionalCollection, ExpressibleByArrayLiteral, SafeSyntax
where Element: SafeSyntax {
  /// Backing `BidirectionalCollection` to which the conformance of this protocol to such type is
  /// delegated.
  ///
  /// > Note: This property **should not** be referenced outside of ``SafeCollection``
  /// implementations.
  var _delegate: [Element] { get }
}

extension SafeCollection where Self: BidirectionalCollection {
  public var startIndex: Int { _delegate.startIndex }
  public var endIndex: Int { _delegate.endIndex }
  public var indices: Range<Int> { _delegate.indices }

  public func index(after i: Int) -> Int { _delegate.index(after: i) }

  public func index(before i: Int) -> Int { _delegate.index(before: i) }

  public func index(_ i: Int, offsetBy distance: Int) -> Int {
    _delegate.index(i, offsetBy: distance)
  }

  public subscript(position: Int) -> Element { _delegate[position] }

  public func distance(from start: Int, to end: Int) -> Int {
    _delegate.distance(from: start, to: end)
  }

  public func formIndex(before i: inout Int) { _delegate.formIndex(before: &i) }

  public func formIndex(after i: inout Int) { _delegate.formIndex(after: &i) }
}

extension SafeCollection where Self: CustomDebugStringConvertible {
  public var debugDescription: String { map(\.debugDescription).description }
}

extension SafeCollection where Self: CustomStringConvertible {
  public var description: String { map(\.description).joined() }
}

extension SafeCollection where Self: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs._delegate == rhs._delegate }
}

extension SafeCollection where Self: Hashable {
  public func hash(into hasher: inout Hasher) {
    node?.id.hash(into: &hasher)
    _delegate.hash(into: &hasher)
  }
}

// MARK: - Element conversions

extension ExprSyntax {
  /// Tries to initialize an `ExprSyntax` from any syntax, resorting to such node itself in case it
  /// is an expression or to any expression which is part of it. A limited set of nodes have
  /// expressions within them, so the initialization will fail if the given one does not.
  ///
  /// - Parameter node: Node from which an `ExprSyntax` will be initialized.
  /// - Returns: Type-erased expression based on the `node` or `nil` if an expression cannot be
  ///   obtained from the `node`.
  fileprivate init?(fromProtocol node: any SyntaxProtocol) {
    if let node = node as? ExprSyntax {
      self = node
    } else if let node = node as? ExprSyntaxProtocol {
      self = ExprSyntax(node)
    } else if let node = node as? ArrayElementSyntax {
      self = node.expression
    } else if let node = node as? LabeledExprSyntax {
      self = node.expression
    } else if let node = ExprSyntax(AsExprSyntax(node)) {
      self = node
    } else {
      return nil
    }
  }
}

/// Converts the elements contained in the `node` into type-erased ``SafeSyntax`` elements and
/// returns them.
///
/// - Parameter node: ``SyntaxCollection`` whose elements will be converted into ``SafeSyntax``
///   ones.
/// - Throws: Never.
func safe(elementsFrom node: any SyntaxCollection) throws -> [AnySafeSyntax] {
  try node.map { nodeElement in AnySafeSyntax(try safe(nodeElement)) }
}

/// Converts the elements contained in the `node` into typed ``SafeSyntax`` elements and returns
/// them.
///
/// - Parameter node: ``SyntaxCollection`` whose elements will be converted into ``SafeSyntax``
///   ones.
/// - Throws: If one of the elements of the `node` cannot be converted into an `Element`.
func safe<Element: SafeSyntax>(elementsFrom node: any SyntaxCollection) throws -> [Element] {
  try node.map { nodeElement in
    try Element._make(
      from: try (try? expect(nodeElement, in: node, toBeOfType: Element.Node.self))
        ?? expect(ExprSyntax(fromProtocol: nodeElement), in: node, toBeOfType: Element.Node.self)
    )
  }
}
