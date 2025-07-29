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

import SwiftSyntax

/// ``SafeSyntax`` of an access to the property of a struct or class or to the case of an enum.
public struct SafeProperty: Identifiable, SafeSyntax {
  public private(set) var node: MemberAccessExprSyntax?
  public let id: String

  public static func _make(from node: MemberAccessExprSyntax) throws -> Self {
    var safe = Self.init(stringLiteral: _extractID(from: node))
    safe.node = node
    return safe
  }
}

extension SafeProperty: CustomDebugStringConvertible {
  public var debugDescription: String { description }
}

extension SafeProperty: CustomStringConvertible {
  public var description: String { id.description }
}

extension SafeProperty: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

extension SafeProperty: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) { self.id = value }
}

/// Makes a ``SafeProperty`` from a `MemberAccessExprSyntax`.
///
/// - Parameter node: Node from which a ``SafeProperty`` will be initialized.
/// - Throws: Never.
public func safe(_ node: MemberAccessExprSyntax) throws -> SafeProperty { try ._make(from: node) }
