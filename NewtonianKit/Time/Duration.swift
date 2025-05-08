//
//  Duration.swift
//  Deus
//
//  Created by Jean Barros Silva on 08/05/25.
//

/// Amount of time in a given unit.
enum Duration: AdditiveArithmetic, Strideable {
  /// Backing, raw value of this ``Duration`` in microseconds.
  private var inMicroseconds: Int {
    switch self {
    case .microseconds(let value):
      value
    case .milliseconds(let value):
      value * 1_000
    }
  }

  static let zero = Self.microseconds(0)

  /// Whether this amount of time is zero or contains a whole millisecond.
  ///
  /// - SeeAlso: ``zero``
  /// - SeeAlso: ``.microseconds(_:)``
  var containsWholeMillisecond: Bool {
    switch self {
    case .microseconds(let value):
      value % 1_000 == 0
    case .milliseconds(_):
      true
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
