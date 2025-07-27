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

/// ``SafeArgument`` containing other ``SafeArgument``s which is based on an array expression
/// containing a collection in which the elements themselves are — hence its indirectness, aspect in
/// which it differs from a ``SafeDirectCollectionArgument``.
public struct SafeIndirectArrayArgument<Element: SafeArgument>: _BidirectionalCollectionDelegator,
  ExpressibleByArrayLiteral, SafeArgument
{
  public let _delegate: [Element]
  public private(set) var syntax: ArrayExprSyntax?
  public var description: String { _delegate.description }

  public init(arrayLiteral elements: Element...) { self = .init(elements) }

  private init(_ delegate: [Element]) { self._delegate = delegate }

  public static func _make(from syntax: ArrayExprSyntax) throws -> Self {
    var argument = Self.init(try _safe(elementsFrom: syntax.elements))
    argument.syntax = syntax
    return argument
  }
}

extension SafeIndirectArrayArgument: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs._delegate == rhs._delegate }
}

/// Makes an indirect array argument from an `ArrayExprSyntax`.
///
/// - Parameters:
///   - syntax: Syntax from which a ``SafeIndirectArrayArgument`` will be initialized.
///   - elementType: Type of the elements in the array.
/// - Throws: If one of the elements in the `SyntaxCollection` cannot be converted into an
///   `Element`.
public func safe<Element: SafeArgument>(
  _ syntax: ArrayExprSyntax,
  containing elementType: Element.Type
) throws -> SafeIndirectArrayArgument<Element> { try ._make(from: syntax) }

// MARK: - Direct collections

/// ``SafeArgument`` containing other ``SafeArgument``s. Its directness stems from its syntax itself
/// being a collection which is not within an expression — unlike that of a
/// ``SafeIndirectArrayArgument``,
public struct SafeDirectCollectionArgument<Syntax: Equatable & SyntaxCollection, Element>:
  _BidirectionalCollectionDelegator, ExpressibleByArrayLiteral, SafeArgument
where Element: SafeArgument {
  public let _delegate: [Element]
  public private(set) var syntax: Syntax?
  public var description: String { _delegate.description }

  public init(arrayLiteral elements: Element...) { self = .init(elements) }

  private init(_ delegate: [Element]) { _delegate = delegate }

  public static func _make(from syntax: Syntax) throws -> Self {
    var argument = Self.init(try _safe(elementsFrom: syntax))
    argument.syntax = syntax
    return argument
  }
}

extension SafeDirectCollectionArgument: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs._delegate == rhs._delegate }
}

/// Makes a direct collection argument from an `ArrayElementListSyntax`.
///
/// - Parameters:
///   - syntax: Syntax from which a ``SafeCollectionArgument`` will be initialized.
///   - elementType: Type of the elements in the collection.
/// - Throws: If one of the elements of the `syntax` cannot be converted into an `Element`.
public func safe<Element: SafeArgument>(
  _ syntax: ArrayElementListSyntax,
  containing elementType: Element.Type
) throws -> SafeDirectCollectionArgument<ArrayElementListSyntax, Element> {
  try ._make(from: syntax)
}

// MARK: - Collection delegation

/// Struct or class which delegates its conformance to `BidirectionalCollection` to a delegate
/// property, forwarding each of the operations of such type to the property. Usages of it are meant
/// to be constrained to collection-based ``SafeArgument``s only.
///
/// - SeeAlso: ``SafeIndirectArrayArgument``
/// - SeeAlso: ``SafeDirectCollectionArgument``
public protocol _BidirectionalCollectionDelegator<Element>: BidirectionalCollection {
  /// Backing `BidirectionCollection` to which the conformance of this struct or class to such type
  /// is delegated.
  ///
  /// > Note: This property should not be referenced by external consumers.
  var _delegate: [Element] { get }
}

extension _BidirectionalCollectionDelegator where Self: BidirectionalCollection {
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

// MARK: - SafeArgument element conversion

/// Converts the elements contained in the `syntax` into ``SafeArgument`` elements and returns them.
///
/// - Parameter syntax: ``SyntaxCollection`` whose elements will be converted into
///   ``SafeArgument`` ones.
/// - Throws: If one of the elements of the `syntax` cannot be converted into an `Element`.
private func _safe<Element: SafeArgument>(
  elementsFrom syntax: any SyntaxCollection
) throws -> [Element] {
  try syntax.compactMap { syntaxElement in
    try Element._make(
      from: try (try? expect(syntaxElement, in: syntax, toBeOfType: Element.Syntax.self))
        ?? expect(
          ExprSyntax(fromProtocol: syntaxElement),
          in: syntax,
          toBeOfType: Element.Syntax.self
        )
    )
  }
}

extension ExprSyntax {
  /// Tries to initialize an `ExprSyntax` from any syntax, resorting to such syntax itself in case
  /// it is an expression or to any expression which is part of it. A limited set of syntaxes have
  /// expressions within them, so the initialization will fail if the given one does not.
  ///
  /// - Parameter syntax: Syntax from which an `ExprSyntax` will be initialized.
  /// - Returns: Type-erased expression based on the `syntax` or `nil` if an expression cannot be
  ///   obtained from the `syntax`.
  fileprivate init?(fromProtocol syntax: any SyntaxProtocol) {
    if let syntax = syntax as? ExprSyntax {
      self = syntax
    } else if let syntax = syntax as? ExprSyntaxProtocol {
      self = ExprSyntax(syntax)
    } else if let syntax = syntax as? ArrayElementSyntax {
      self = syntax.expression
    } else if let syntax = syntax as? LabeledExprSyntax {
      self = syntax.expression
    } else if let syntax = ExprSyntax(AsExprSyntax(syntax)) {
      self = syntax
    } else {
      return nil
    }
  }
}
