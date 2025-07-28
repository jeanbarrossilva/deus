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

/// ``SafeArgument`` of an integer.
public struct SafeIntArgument: SafeArgument {
  public static let _nonIntegerLiteralDiagnosticID = MessageID(
    domain: "StandardModelKitMacros",
    id: "NonIntegerLiteral"
  )

  public private(set) var syntax: IntegerLiteralExprSyntax?

  private let _delegate: Int

  public static func _make(from syntax: IntegerLiteralExprSyntax) throws -> Self {
    guard let delegate = Int(syntax.literal.text) else {
      throw DiagnosticsError(diagnostics: [
        Diagnostic(
          node: syntax,
          message: SimpleDiagnosticMessage(
            message: "\((try? safe(syntax.literal))?.debugDescription ?? syntax.description) is "
              + "not an integer",
            diagnosticID: _nonIntegerLiteralDiagnosticID,
            severity: .error
          )
        )
      ])
    }
    var argument = Self.init(integerLiteral: delegate)
    argument.syntax = syntax
    return argument
  }
}

extension SafeIntArgument: CustomDebugStringConvertible {
  public var debugDescription: String { description }
}

extension SafeIntArgument: CustomStringConvertible {
  public var description: String { _delegate.description }
}

extension SafeIntArgument: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs._delegate == rhs._delegate }
}

extension SafeIntArgument: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Int) { self._delegate = value }
}

extension SafeIntArgument: SignedInteger {
  public static var zero: Self { .init(integerLiteral: 0) }
  public static var isSigned: Bool { Int.isSigned }
  public static var max: Self { .init(integerLiteral: .max) }
  public static var min: Self { .init(integerLiteral: .min) }

  public var words: Int.Words { _delegate.words }
  public var bitWidth: Int { _delegate.bitWidth }
  public var trailingZeroBitCount: Int { _delegate.trailingZeroBitCount }
  public var nonzeroBitCount: Int { _delegate.nonzeroBitCount }
  public var leadingZeroBitCount: Int { _delegate.leadingZeroBitCount }
  public var magnitude: Int.Magnitude { _delegate.magnitude }
  public var hashValue: Int { _delegate.hashValue }
  public var bigEndian: Self { .init(integerLiteral: _delegate.bigEndian) }
  public var littleEndian: Self { .init(integerLiteral: _delegate.littleEndian) }
  public var byteSwapped: Self { .init(integerLiteral: _delegate.byteSwapped) }

  public init?<T: BinaryFloatingPoint>(exactly source: T) {
    guard let source = Int(exactly: source) else { return nil }
    self = .init(integerLiteral: source)
  }

  public init<T: BinaryInteger>(_ source: T) { self = .init(integerLiteral: .init(source)) }

  public init<T: BinaryInteger>(truncatingIfNeeded source: T) {
    self = .init(integerLiteral: .init(truncatingIfNeeded: source))
  }

  public init<T: BinaryInteger>(clamping source: T) {
    self = .init(integerLiteral: .init(clamping: source))
  }

  public init<T: BinaryFloatingPoint>(_ source: T) { self = .init(integerLiteral: .init(source)) }

  public init?<T: BinaryInteger>(exactly source: T) {
    guard let source = Int(exactly: source) else { return nil }
    self = .init(integerLiteral: source)
  }

  public init(_truncatingBits bits: UInt) {
    self = .init(integerLiteral: .init(truncatingIfNeeded: bits))
  }

  public init(bigEndian value: SafeIntArgument) {
    self = .init(integerLiteral: value._delegate.bigEndian)
  }

  public init(littleEndian value: SafeIntArgument) {
    self = .init(integerLiteral: value._delegate.littleEndian)
  }

  public init(byteSwapped value: SafeIntArgument) {
    self = .init(integerLiteral: value._delegate.byteSwapped)
  }

  public static func + (lhs: Self, rhs: Self) -> Self {
    .init(integerLiteral: lhs._delegate + rhs._delegate)
  }

  public static func += (lhs: inout Self, rhs: Self) { lhs = lhs + rhs }

  public static func - (lhs: Self, rhs: Self) -> Self {
    .init(integerLiteral: lhs._delegate - rhs._delegate)
  }

  public static func -= (lhs: inout Self, rhs: Self) { lhs = lhs - rhs }

  public static func * (lhs: Self, rhs: Self) -> Self {
    .init(integerLiteral: lhs._delegate * rhs._delegate)
  }

  public static func *= (lhs: inout Self, rhs: Self) { lhs = lhs * rhs }

  public static func / (lhs: Self, rhs: Self) -> Self {
    .init(integerLiteral: lhs._delegate / rhs._delegate)
  }

  public static func /= (lhs: inout Self, rhs: Self) { lhs = lhs / rhs }

  public static func % (lhs: Self, rhs: Self) -> Self {
    .init(integerLiteral: lhs._delegate % rhs._delegate)
  }

  public static func %= (lhs: inout Self, rhs: Self) { lhs = lhs % rhs }

  public static func & (lhs: Self, rhs: Self) -> Self {
    .init(integerLiteral: lhs._delegate & rhs._delegate)
  }

  public static func &= (lhs: inout Self, rhs: Self) { lhs = lhs & rhs }

  public static func | (lhs: Self, rhs: Self) -> Self {
    .init(integerLiteral: lhs._delegate | rhs._delegate)
  }

  public static func |= (lhs: inout Self, rhs: Self) { lhs = lhs | rhs }

  public static func ^ (lhs: Self, rhs: Self) -> Self {
    .init(integerLiteral: lhs._delegate ^ rhs._delegate)
  }

  public static func ^= (lhs: inout Self, rhs: Self) { lhs = lhs ^ rhs }

  public static prefix func ~ (x: Self) -> Self { .init(integerLiteral: ~x._delegate) }

  public static func << <RHS: BinaryInteger>(lhs: Self, rhs: RHS) -> Self {
    .init(integerLiteral: lhs._delegate << rhs)
  }

  public static func <<= <RHS: BinaryInteger>(lhs: inout Self, rhs: RHS) { lhs = lhs << rhs }

  public static func >> <RHS: BinaryInteger>(lhs: Self, rhs: RHS) -> Self {
    .init(integerLiteral: lhs._delegate >> rhs)
  }

  public static func >>= <RHS: BinaryInteger>(lhs: inout Self, rhs: RHS) { lhs = lhs >> rhs }

  public static func ..< (lhs: Self, rhs: Self) -> Range<Self> {
    Range(uncheckedBounds: (lower: lhs, upper: rhs))
  }

  public static func ... (lhs: Self, rhs: Self) -> ClosedRange<Self> {
    ClosedRange(uncheckedBounds: (lower: lhs, upper: rhs))
  }

  public static func < (lhs: Self, rhs: Self) -> Bool { lhs._delegate < rhs._delegate }

  public static func > (lhs: Self, rhs: Self) -> Bool { lhs._delegate > rhs._delegate }

  public static func <= (lhs: Self, rhs: Self) -> Bool { lhs._delegate <= rhs._delegate }

  public static func >= (lhs: Self, rhs: Self) -> Bool { lhs._delegate >= rhs._delegate }

  public func distance(to other: Self) -> Int { _delegate.distance(to: other._delegate) }

  public func advanced(by n: Int) -> Self { .init(integerLiteral: _delegate.advanced(by: n)) }

  public func hash(into hasher: inout Hasher) { _delegate.hash(into: &hasher) }
}

/// Makes an int argument from an `IntegerLiteralExprSyntax`.
///
/// - Parameter syntax: Syntax from which a ``SafeIntArgument`` will be initialized.
/// - Throws: If the literal is not an integer.
public func safe(_ syntax: IntegerLiteralExprSyntax) throws -> SafeIntArgument {
  try ._make(from: syntax)
}
