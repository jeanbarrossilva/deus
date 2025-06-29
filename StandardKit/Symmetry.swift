//
//  Symmetry.swift
//  Deus
//
//  Created by Jean Barros Silva on 02/06/25.
//

import Geometry
import Numerics

// MARK: - U(1)
extension Complex<Double> {
  /// Performs a global transformation on the phase of this quantum state on the unidimensional
  /// Abelian unit group U(1) (a unit circle) by rotating its phase while maintaining its magnitude.
  ///
  /// ## Formula
  ///
  /// U(1) = exp(*i* × θ)
  ///
  /// - Parameter theta: ``Angle`` of the rotation.
  func u1(by theta: Angle) -> Self {
    self * .exp(.i * theta.value)
  }
}
