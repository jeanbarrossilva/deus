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

/// ``SafeCollectionArgument`` which is based on an array expression containing a collection in
/// which the child syntaxes themselves are — hence its indirectness, aspect in which it differs
/// from a ``SafeDirectCollectionArgument``.
public struct SafeIndirectArrayArgument<Element: SafeArgument>: SafeCollectionArgument {
  public let _delegate: [Element]
  public private(set) var syntax: ArrayExprSyntax?

  public init(arrayLiteral elements: Element...) { self = .init(delegate: elements) }

  private init(delegate: [Element]) { self._delegate = delegate }

  public static func _make(from syntax: ArrayExprSyntax) throws -> Self {
    var argument = Self.init(delegate: try safe(elementsFrom: syntax.elements))
    argument.syntax = syntax
    return argument
  }
}

/// ``SafeCollectionArgument`` whose elements are type-erased and which is based on an array
/// expression containing a collection in which the child syntaxes themselves are — hence its
/// indirectness, aspect in which it differs from a ``SafeDirectCollectionArgument``.
public struct SafeIndirectArrayWithTypeErasedElementsArgument: SafeCollectionArgument {
  public typealias Element = AnySafeArgument

  public let _delegate: [AnySafeArgument]
  public private(set) var syntax: ArrayExprSyntax?

  private init(delegate: [AnySafeArgument]) { _delegate = delegate }

  public static func _make(from syntax: ArrayExprSyntax) throws -> Self {
    var argument = Self.init(delegate: try safe(elementsFrom: syntax.elements))
    argument.syntax = syntax
    return argument
  }
}

extension SafeIndirectArrayWithTypeErasedElementsArgument: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: AnySafeArgument...) { self = .init(delegate: elements) }
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

/// Makes an indirect array argument whose elements are type-erased from an `ArrayExprSyntax`.
///
/// - Parameters:
///   - syntax: Syntax from which a ``SafeIndirectArrayWithTypeErasedElementsArgument`` will be
///     initialized.
/// - Throws: Never.
public func safe(
  _ syntax: ArrayExprSyntax
) throws -> SafeIndirectArrayWithTypeErasedElementsArgument { try ._make(from: syntax) }

// MARK: - Direct collections

/// ``SafeCollectionArgument`` whose directness stems from its syntax itself being a collection
/// which is not within an expression — unlike that of a ``SafeIndirectArrayArgument``, which
/// *contains* a collection of syntaxes instead.
public struct SafeDirectCollectionArgument<
  Syntax: Equatable & SyntaxCollection,
  Element: SafeArgument
>: SafeCollectionArgument {
  public let _delegate: [Element]
  public private(set) var syntax: Syntax?

  public init(arrayLiteral elements: Element...) { self = .init(elements) }

  private init(_ delegate: [Element]) { _delegate = delegate }

  public static func _make(from syntax: Syntax) throws -> Self {
    var argument = Self.init(try safe(elementsFrom: syntax))
    argument.syntax = syntax
    return argument
  }
}

/// ``SafeCollectionArgument`` whose elements are type-erased and directness stems from its syntax
/// itself being a collection which is not within an expression — unlike that of a
/// ``SafeIndirectArrayWithTypeErasedElementsArgument``, which *contains* a collection of syntaxes
/// instead.
public struct SafeDirectCollectionWithTypeErasedElementsArgument<
  Syntax: Equatable & SyntaxCollection
>: SafeCollectionArgument {
  public typealias Element = AnySafeArgument

  public let _delegate: [AnySafeArgument]
  public private(set) var syntax: Syntax?

  public init(arrayLiteral elements: AnySafeArgument...) { self = .init(elements) }

  init(_ delegate: [AnySafeArgument]) { _delegate = delegate }

  public static func _make(from syntax: Syntax) throws -> Self {
    var argument = Self.init(try safe(elementsFrom: syntax))
    argument.syntax = syntax
    return argument
  }
}

/// Makes an direct collection argument whose elements are type-erased from a `SyntaxCollection`.
///
/// - Parameters:
///   - syntax: Syntax from which a ``SafeDirectCollectionWithTypeErasedElementsArgument`` will be
///     initialized.
/// - Throws: Never.
public func safe<Syntax: Equatable & SyntaxCollection>(
  _ syntax: Syntax
) throws -> SafeDirectCollectionWithTypeErasedElementsArgument<Syntax> { try ._make(from: syntax) }

/// Makes a direct collection argument from an `ArrayElementListSyntax`.
///
/// - Parameters:
///   - syntax: Syntax from which a ``SafeDirectCollectionArgument`` will be initialized.
///   - elementType: Type of the elements in the collection.
/// - Throws: If one of the elements of the `syntax` cannot be converted into an `Element`.
public func safe<Element: SafeArgument>(
  _ syntax: ArrayElementListSyntax,
  containing elementType: Element.Type
) throws -> SafeDirectCollectionArgument<ArrayElementListSyntax, Element> {
  try ._make(from: syntax)
}

// MARK: - Collection basis

/// ``SafeArgument`` which is a container of other ``SafeArgument``s.
public protocol SafeCollectionArgument: BidirectionalCollection, ExpressibleByArrayLiteral,
  SafeArgument
where Element: SafeArgument {
  /// Backing `BidirectionalCollection` to which the conformance of this protocol to such type is
  /// delegated.
  ///
  /// > Note: This property **should not** be referenced outside of ``SafeCollectionArgument``
  /// implementations.
  var _delegate: [Element] { get }
}

extension SafeCollectionArgument where Self: BidirectionalCollection {
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

extension SafeCollectionArgument where Self: CustomDebugStringConvertible {
  public var debugDescription: String { map(\.debugDescription).description }
}

extension SafeCollectionArgument where Self: CustomStringConvertible {
  public var description: String { map(\.description).joined() }
}

extension SafeCollectionArgument where Self: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs._delegate == rhs._delegate }
}

extension SafeCollectionArgument where Self: Hashable {
  public func hash(into hasher: inout Hasher) {
    syntax?.id.hash(into: &hasher)
    _delegate.hash(into: &hasher)
  }
}

// MARK: - Element conversions

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

/// Converts the elements contained in the `syntax` into type-erased ``SafeArgument`` elements and
/// returns them.
///
/// - Parameter syntax: ``SyntaxCollection`` whose elements will be converted into
///   ``SafeArgument`` ones.
/// - Throws: If one of the elements of the `syntax` cannot be converted into an `Element`.
func safe(elementsFrom syntax: any SyntaxCollection) throws -> [AnySafeArgument] {
  try syntax.compactMap { syntaxElement in AnySafeArgument(try safe(syntax)) }
}

/// Converts the elements contained in the `syntax` into typed ``SafeArgument`` elements and returns
/// them.
///
/// - Parameter syntax: ``SyntaxCollection`` whose elements will be converted into
///   ``SafeArgument`` ones.
/// - Throws: If one of the elements of the `syntax` cannot be converted into an `Element`.
func safe<Element: SafeArgument>(elementsFrom syntax: any SyntaxCollection) throws -> [Element] {
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
