//
//  Duration.swift
//  Deus
//
//  Created by Jean Barros Silva on 08/05/25.
//

/// Amount of time in a given unit.
enum Duration: AdditiveArithmetic, Strideable {
  static let zero = Self.microseconds(0)

  /// Amount of microseconds — the backing unit of a ``Duration`` — in a microsecond. Logically, 1.
  static let microsecondFactor = 1

  /// Amount of microseconds — the backing unit of a ``Duration`` — in a millisecond.
  static let millisecondFactor = 1_000

  /// Backing, raw value of this ``Duration`` in microseconds.
  var inMicroseconds: Int {
    switch self {
    case .microseconds(let value):
      value * Self.microsecondFactor
    case .milliseconds(let value):
      value * Self.millisecondFactor
    }
  }

  /// Amount of time in microseconds.
  case microseconds(Int)

  /// Amount of time in milliseconds.
  case milliseconds(Int)

  static func + (lhs: Self, rhs: Self) -> Self {
    if lhs == .zero {
      rhs
    } else if rhs == .zero {
      lhs
    } else {
      .microseconds(lhs.inMicroseconds + rhs.inMicroseconds)
    }
  }

  static func += (lhs: inout Self, rhs: Self) {
    lhs = lhs + rhs
  }

  static func - (lhs: Self, rhs: Self) -> Self {
    if rhs == .zero { lhs } else { .microseconds(lhs.inMicroseconds - rhs.inMicroseconds) }
  }

  static func -= (lhs: inout Self, rhs: Self) {
    lhs = lhs - rhs
  }

  func distance(to other: Self) -> Int {
    inMicroseconds.distance(to: other.inMicroseconds)
  }

  func advanced(by n: Int) -> Self {
    n == -inMicroseconds ? .zero : n == 0 ? self : .microseconds(inMicroseconds + n)
  }
}
