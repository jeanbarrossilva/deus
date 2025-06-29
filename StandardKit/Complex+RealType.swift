//
//  Complex+Real.swift
//  Deus
//
//  Created by Jean Barros Silva on 02/06/25.
//

import Numerics

extension Complex {
  /// Multiplies the real and imaginary parts of a complex number by a scalar.
  ///
  /// - Parameters:
  ///   - lhs: Complex number to be multiplied by `rhs`.
  ///   - rhs: Scalar by which each part of `lhs` is multiplied.
  static func * (lhs: Self, rhs: RealType) -> Self {
    guard rhs != 1 else { return lhs }
    return .init(lhs.real * rhs, lhs.imaginary * rhs)
  }
}
