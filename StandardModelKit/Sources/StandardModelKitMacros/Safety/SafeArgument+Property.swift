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

/// ``SafeArgument`` of an access to the property of a struct or class or to the case of an enum.
public struct SafePropertyArgument: Identifiable, SafeArgument {
  public private(set) var syntax: MemberAccessExprSyntax?
  public let id: String

  public static func _make(from syntax: MemberAccessExprSyntax) throws -> SafePropertyArgument {
    var argument = Self.init(stringLiteral: _extractID(from: syntax))
    argument.syntax = syntax
    return argument
  }
}

extension SafePropertyArgument: CustomDebugStringConvertible {
  public var debugDescription: String { description }
}

extension SafePropertyArgument: CustomStringConvertible {
  public var description: String { id.description }
}

extension SafePropertyArgument: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

extension SafePropertyArgument: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) { self.id = value }
}

/// Makes a callable argument from a `MemberAccessExprSyntax`.
///
/// - Parameter syntax: Syntax from which a ``SafePropertyArgument`` will be initialized.
/// - Throws: Never.
public func safe(_ syntax: MemberAccessExprSyntax) throws -> SafePropertyArgument {
  try ._make(from: syntax)
}
