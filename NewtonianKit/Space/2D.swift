//
//  2D.swift
//  Deus
//
//  Created by Jean Barros Silva on 28/04/25.
//

import Foundation

/// Abstraction of an exact location on or movement across a 2D plane.
protocol TwoD: AdditiveArithmetic, CustomStringConvertible {
  /// Final position in the x-axis.
  var x: Double { get }
  
  /// Final position in the y-axis.
  var y: Double { get }

  /// Initializes a 2D abstraction with the given coordinates.
  ///
  /// - Parameters:
  ///   - x: Final position in the x-axis.
  ///   - y: Final position in the y-axis.
  init(x: Double, y: Double)
}

extension TwoD {
  /// Initializes a 2D abstraction based on an existing one.
  ///
  /// - Parameter base: 2D abstraction whose coordinates will be set to those of the initialized
  ///   one.
  init<B: TwoD>(from base: B) {
    self = .at(x: base.x, y: base.y)
  }
  
  /// Multiplies each coordinate of the 2D abstraction by the value.
  ///
  /// - Parameters:
  ///   - lhs: 2D abstraction whose coordinates will be multiplied by the value.
  ///   - rhs: Value by which the coordinates of the 2D abstraction will be multiplied.
  /// - Returns: Another 2D abstraction whose coordinates are the result of multiplying those of the
  ///   given one by the value; or the given 2D abstraction itself in case it was multiplied by 1.
  static func * (lhs: Self, rhs: Double) -> Self {
    guard rhs != 1 else { return lhs }
    return .at(x: lhs.x * rhs, y: lhs.y * rhs)
  }
  
  /// Returns a 2D abstraction at the given coordinates.
  ///
  /// - Parameters:
  ///   - x: Final position in the x-axis.
  ///   - y: Final position in the y-axis.
  static func at(x: Double, y: Double) -> Self {
    x == 0 && y == 0 ? .zero : .init(x: x, y: y)
  }

  /// Multiplies this 2D abstraction by the other via scalar/dot product.
  ///
  /// - Parameter rhs: 2D abstraction by which this one will be multiplied.
  /// - Returns: The resultant scalar value.
  func scalar(_ rhs: Self) -> Double {
    x * rhs.x + y * rhs.y
  }

  /// Multiplies this 2D abstraction by the other via cross product.
  ///
  /// - Parameter rhs: 2D abstraction by which this one will be multiplied.
  /// - Returns: The resultant cross product.
  func cross(_ rhs: Self) -> Double {
    x * rhs.x - y * rhs.y
  }
}

extension TwoD where Self: Equatable {
  /// Determines whether both 2D abstractions end up in the same position.
  ///
  /// - Parameters:
  ///   - lhs: 2D abstraction to be compared with ``rhs``.
  ///   - rhs: 2D abstraction to be compared with ``lhs``.
  /// - Returns: `true` when both 2D abstractions are equal; or `false` when their final coordinates
  ///   differ.
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.x == rhs.x && lhs.y == rhs.y
  }
}

extension TwoD where Self: AdditiveArithmetic {
  static func + (lhs: Self, rhs: Self) -> Self {
    guard lhs != .zero else { return rhs }
    guard rhs != .zero else { return lhs }
    return .at(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
  }
  
  static func - (lhs: Self, rhs: Self) -> Self {
    guard lhs != rhs else { return .zero }
    guard rhs != .zero else { return lhs }
    return .at(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
  }
}

extension TwoD where Self: CustomStringConvertible {
  var description: String { "(\(x), \(y))" }
}

/// An exact location in a 2D plane.
struct Point: TwoD {
  static var zero = Self.init(x: 0, y: 0)

  let x: Double
  let y: Double

  internal init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }
}

/// Movement across a bidimensional plane.
final class Vector: TwoD {
  static var zero = Vector(x: 0, y: 0)

  /// Offset in the x-axis relative to a previous  ``Vector``.
  let x: Double

  /// Offset in the y-axis relative to a previous ``Vector``.
  let y: Double

  /// Distance between the zero ``Vector`` and this one; is, essentially, its length.
  public private(set) lazy var module = sqrtl(x * x + y * y)

  /// ``Vector`` whose direction is the same as that of this one, but with a module of 1.
  public private(set) lazy var unitary =
    self === Self.zero ? nil : module == 1 ? self : Self.at(x: x / module, y: y / module)

  internal init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }

  static func < (lhs: Vector, rhs: Vector) -> Bool {
    lhs.module < rhs.module
  }

  static func > (lhs: Vector, rhs: Vector) -> Bool {
    lhs.module > rhs.module
  }
}
