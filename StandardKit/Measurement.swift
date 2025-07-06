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

import Foundation

/// `NumberFormatter` by which the specified quantity is described in a string alongside its symbol.
///
/// - SeeAlso: ``Measurement/description``
/// - SeeAlso: ``Measurement/symbol``
private let valueFormatter = {
  let formatter = NumberFormatter()
  formatter.usesGroupingSeparator = true
  formatter.maximumFractionDigits = 2
  return formatter
}()

/// Amount dependent of a system of units defined by the International System of Units (SI).
public protocol Measurement: Comparable, CustomStringConvertible, SignedNumeric {
  /// ``symbol`` of the backing unit of this ``Measurement``.
  static var backingUnitSymbol: String { get }

  /// Amount in the backing unit.
  var value: Double { get }

  /// Abbreviated textual representation of the unit as per the SI.
  var symbol: String { get }

  /// Makes a ``Measurement`` in its backing unit.
  ///
  /// - Parameter value: Raw value in the backing unit.
  static func make(value: Double) -> Self
}

extension Measurement where Self: Comparable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.value == rhs.value
  }

  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.value < rhs.value
  }

  public static func > (lhs: Self, rhs: Self) -> Bool {
    lhs.value > rhs.value
  }
}

extension Measurement where Self: CustomStringConvertible {
  /// Describes the dimensioned value and unit in which it was quantified (e.g., "2 cm").
  public var description: String {
    guard let formattedValue = valueFormatter.string(for: value) else {
      return "\(value) \(symbol)"
    }
    return "\(formattedValue) \(symbol)"
  }
}

extension Measurement where Self: SignedNumeric {
  public var magnitude: Double { abs(value) }

  public init?<T>(exactly source: T) where T: BinaryInteger {
    self = .init(integerLiteral: Int(source))
  }

  public init(integerLiteral value: Int) {
    self = value == 0 ? .zero : .make(value: Double(value))
  }

  public static func + (lhs: Self, rhs: Self) -> Self {
    guard lhs != .zero else { return rhs }
    guard rhs != .zero else { return lhs }
    guard lhs != .zero - rhs else { return .zero }
    return .make(value: lhs.value + rhs.value)
  }

  public static func - (lhs: Self, rhs: Self) -> Self {
    guard lhs != rhs else { return .zero }
    guard rhs != zero else { return lhs }
    return .make(value: lhs.value - rhs.value)
  }

  public static func * (lhs: Self, rhs: Self) -> Self {
    guard lhs != .zero || rhs == .zero else { return .zero }
    guard lhs.value != 1 || rhs.value == 1 else { return lhs }
    return .make(value: lhs.value * rhs.value)
  }

  public static func *= (lhs: inout Self, rhs: Self) {
    lhs = lhs * rhs
  }

  public prefix static func - (operand: Self) -> Self {
    .make(value: -operand.value)
  }

  public mutating func negate() {
    self -= self
  }
}
