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

/// Type-safe, compile-time argument passed into a macro.
public protocol SafeArgument<Syntax>: CustomStringConvertible, Equatable {
  /// `SwiftSyntax` type equivalent to this type of argument.
  associatedtype Syntax: SyntaxProtocol

  /// Syntax from which this argument was initialized or `nil` in case it was not initialized from a
  /// syntax, but, rather, directly.
  var syntax: Syntax? { get }

  /// Makes an argument of this type from the `syntax`.
  ///
  /// > Note: the ``syntax`` property **should** have been assigned by the time this function
  /// returns.
  ///
  /// - Parameter syntax: `SwiftSyntax` syntax from which this type of argument will be
  ///   initialized.
  static func _make(from syntax: Syntax) throws -> Self
}
