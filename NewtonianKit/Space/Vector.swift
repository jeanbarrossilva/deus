//
//  Vector.swift
//  Deus
//
//  Created by Jean Barros Silva on 28/04/25.
//

/// Pair of coordinates in a bi-dimensional Cartesian plane.
class Vector: Comparable {
  /// ``Vector`` whose coordinates and module are zero and which does not have a unitary ``Vector``.
  ///
  /// Has no length, direction or sense.
  private static let zero = Vector(x: 0, y: 0)

  /// Horizontal coordinate.
  let x: Float

  /// Vertical coordinate.
  let y: Float

  /// Distance between the zero ``Vector`` and this one; is, essentially, its length.
  public private(set) lazy var module: Float = (x * x + y * y).squareRoot()

  /// ``Vector`` whose direction is the same as that of this one, but with a module of 1.
  public private(set) lazy var unitary =
    self === Self.zero ? nil : module == 1 ? self : .init(x: x / module, y: y / module)

  private init(x: Float, y: Float) {
    self.x = x
    self.y = y
  }

  static func < (lhs: Vector, rhs: Vector) -> Bool {
    lhs.module < rhs.module
  }

  static func == (lhs: Vector, rhs: Vector) -> Bool {
    lhs.x == rhs.x && lhs.y == rhs.y
  }

  static func > (lhs: Vector, rhs: Vector) -> Bool {
    lhs.module > rhs.module
  }

  static func + (lhs: Vector, rhs: Vector) -> Vector {
    if lhs === Self.zero {
      return rhs
    } else if rhs === Self.zero {
      return lhs
    } else {
      return .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
  }

  static func - (lhs: Vector, rhs: Vector) -> Vector {
    if lhs == rhs {
      return .zero
    } else if rhs === Self.zero {
      return lhs
    } else {
      return .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
  }

  static func * (lhs: Vector, rhs: Vector) -> Float {
    lhs.x * rhs.x + lhs.y * rhs.y
  }

  static func * (lhs: Vector, rhs: Float) -> Vector {
    switch rhs {
    case 0:
      return .zero
    case 1:
      return lhs
    default:
      return .init(x: lhs.x * rhs, y: lhs.y * rhs)
    }
  }

  /// Returns a ``Vector``.
  static func at(x: Float, y: Float) -> Vector {
    x == 0 && y == 0 ? .zero : .init(x: x, y: y)
  }
}
