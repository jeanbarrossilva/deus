//
//  Duration.swift
//  RelativityKit
//
//  Created by Jean Barros Silva on 08/05/25.
//

/// Amount of time in a given unit.
public enum Duration: AdditiveArithmetic, Strideable {
  public static let zero = Self.microseconds(0)

  /// Amount of microseconds — the backing unit of a ``Duration`` — in a microsecond. Logically, 1.
  static let microsecondFactor = 1

  /// Amount of microseconds — the backing unit of a ``Duration`` — in a millisecond.
  static let millisecondFactor = 1_000

  /// Amount of microseconds — the backing unit of a ``Duration`` — in a second.
  static let secondFactor = 1_000_000

  /// Backing, raw value of this ``Duration`` in microseconds.
  var inMicroseconds: Int {
    switch self {
    case .microseconds(let value):
      value
    case .milliseconds(let value):
      value * Self.millisecondFactor
    case .seconds(let value):
      value * Self.secondFactor
    }
  }

  /// Conversion of this ``Duration`` into milliseconds.
  var inMilliseconds: Double {
    switch self {
    case .microseconds(let value):
      Double(value) / Double(Self.millisecondFactor)
    case .milliseconds(let value):
      Double(value)
    case .seconds(let value):
      Double(value) * Double(Self.secondFactor) / Double(Self.millisecondFactor)
    }
  }

  /// Amount of time in microseconds.
  case microseconds(Int)

  /// Amount of time in milliseconds.
  case milliseconds(Int)

  /// Amount of time in seconds.
  case seconds(Int)

  /// Sums one ``Duration`` to another.
  ///
  /// - Parameters:
  ///   - lhs: ``Duration`` to which `rhs` will be summed.
  ///   - rhs: ``Duration`` to sum to `lhs`.
  /// - Returns: Sum of `lhs` and `rhs`.
  public static func + (lhs: Self, rhs: Self) -> Self {
    if lhs == .zero {
      rhs
    } else if rhs == .zero {
      lhs
    } else {
      .microseconds(lhs.inMicroseconds + rhs.inMicroseconds)
    }
  }

  /// Assigns the sum of one ``Duration`` by another to `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: ``Duration`` to which `rhs` will be summed and the sum will be assigned.
  ///   - rhs: ``Duration`` to sum to `lhs`.
  public static func += (lhs: inout Self, rhs: Self) {
    lhs = lhs + rhs
  }

  /// Subtracts one ``Duration`` from another.
  ///
  /// - Parameters:
  ///   - lhs: ``Duration`` from which `rhs` will be subtracted.
  ///   - rhs: ``Duration`` to subtract from `lhs`.
  /// - Returns: Difference between `lhs` and `rhs`.
  public static func - (lhs: Self, rhs: Self) -> Self {
    if rhs == .zero { lhs } else { .microseconds(lhs.inMicroseconds - rhs.inMicroseconds) }
  }

  /// Assigns the difference between one ``Duration`` and another.
  ///
  /// - Parameters:
  ///   - lhs: ``Duration`` from which `rhs` will be subtracted and to which the difference will be
  ///     assigned.
  ///   - rhs: ``Duration`` to subtract from `lhs`.
  public static func -= (lhs: inout Self, rhs: Self) {
    lhs = lhs - rhs
  }

  public func distance(to other: Self) -> Int {
    inMicroseconds.distance(to: other.inMicroseconds)
  }

  public func advanced(by n: Int) -> Self {
    guard n != 0 else { return self }
    return .microseconds(inMicroseconds + n)
  }
}
