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

/// ID of the diagnostic of a string which cannot be evaluted.
///
/// - SeeAlso: ``safe(_:)->SafeString``
public let _safeStringUnevaluableLiteralDiagnosticID = MessageID(
  domain: "StandardModelKitMacros",
  id: "StringLiteralUnevaluability"
)

/// ``SafeSyntax`` of a string.
public struct SafeString: SafeSyntax {
  /// `String` to which `CustomStringConvertible` and `StringProtocol` conformances are delegated.
  private var delegate: String

  public private(set) var node: StringLiteralExprSyntax?

  public static func _make(from node: StringLiteralExprSyntax) throws(DiagnosticsError) -> Self {
    guard let value = StringLiteral(node).value else {
      throw DiagnosticsError(diagnostics: [
        Diagnostic(
          node: node,
          message: SimpleDiagnosticMessage(
            message: "\"\(node)\" could not be evaluated",
            diagnosticID: _safeStringUnevaluableLiteralDiagnosticID,
            severity: .error
          )
        )
      ])
    }
    var safe = Self.init(stringLiteral: value)
    safe.node = node
    return safe
  }
}

extension SafeString: CustomDebugStringConvertible {
  public var debugDescription: String { "\"\(description)\"" }
}

extension SafeString: CustomStringConvertible {
  public var description: String { delegate.description }
}

extension SafeString: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs.delegate == rhs.delegate }
}

extension SafeString: StringProtocol {
  public var startIndex: String.Index { delegate.startIndex }
  public var endIndex: String.Index { delegate.endIndex }
  public var utf8: String.UTF8View { delegate.utf8 }
  public var utf16: String.UTF16View { delegate.utf16 }
  public var unicodeScalars: String.UnicodeScalarView { delegate.unicodeScalars }

  public init<C: Collection, Encoding: _UnicodeEncoding>(
    decoding codeUnits: C,
    as sourceEncoding: Encoding.Type
  ) where C.Element == Encoding.CodeUnit {
    self = .init(stringLiteral: StringLiteralType(decoding: codeUnits, as: sourceEncoding))
  }

  public init(cString nullTerminatedUTF8: UnsafePointer<CChar>) {
    self = .init(stringLiteral: .init(cString: nullTerminatedUTF8))
  }

  public init<Encoding: _UnicodeEncoding>(
    decodingCString nullTerminatedCodeUnits: UnsafePointer<Encoding.CodeUnit>,
    as sourceEncoding: Encoding.Type
  ) {
    self = .init(stringLiteral: .init(decodingCString: nullTerminatedCodeUnits, as: sourceEncoding))
  }

  public init?(_ description: String) { delegate = description }

  public init(stringLiteral value: String) { delegate = value }

  public subscript(position: String.Index) -> Character { delegate[position] }

  public subscript(bounds: Range<String.Index>) -> Substring { delegate[bounds] }

  public func index(after i: String.Index) -> String.Index { delegate.index(after: i) }

  public func index(before i: String.Index) -> String.Index { delegate.index(before: i) }

  public func index(_ i: String.Index, offsetBy distance: Int) -> String.Index {
    delegate.index(i, offsetBy: distance)
  }

  public func index(
    _ i: String.Index,
    offsetBy distance: Int,
    limitedBy limit: String.Index
  ) -> String.Index? { delegate.index(i, offsetBy: distance, limitedBy: limit) }

  public func distance(from start: String.Index, to end: String.Index) -> Int {
    delegate.distance(from: start, to: end)
  }

  public mutating func write(_ other: String) { delegate.write(other) }

  public func write<Target: TextOutputStream>(to target: inout Target) { target.write(delegate) }

  public func withCString<Result>(
    _ body: (UnsafePointer<CChar>) throws -> Result
  ) rethrows -> Result { try delegate.withCString(body) }

  public func withCString<Result, Encoding>(
    encodedAs targetEncoding: Encoding.Type,
    _ body: (UnsafePointer<Encoding.CodeUnit>) throws -> Result
  ) rethrows -> Result where Encoding: _UnicodeEncoding {
    try delegate.withCString(encodedAs: targetEncoding, body)
  }

  public func lowercased() -> String { delegate.lowercased() }

  public func uppercased() -> String { delegate.uppercased() }
}

/// Makes a ``SafeString`` from a ``StringLiteralExprSyntax``.
///
/// - Parameter node: Node from which a ``SafeString`` will be initialized.
/// - Throws: If the string cannot be evaluated. The limitations on such evaluation themselves are
///   unclear and stem from `MacroToolkit`, in which is stated that it is unevaluable when it
///   contains interpolation — despite the fact that, even when it does, evaluation occurs
///   successfully.
public func safe(_ node: StringLiteralExprSyntax) throws -> SafeString { try ._make(from: node) }
