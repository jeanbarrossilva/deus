//
//  Symmetry.swift
//  Deus
//
//  Created by Jean Barros Silva on 02/06/25.
//

import Numerics
import Testing

@testable import StandardKit

struct SymmetryTests {
  @Suite("U1") struct U1Tests {
    @Test func fieldIsUntransformedWhenUnrotated() {
      #expect(Complex(2, 4).u1(by: .zero) == Complex(2, 4))
    }

    @Test(arguments: stride(from: 2, to: 64, by: 2).map { Angle.radians(.pi * $0) })
    func fieldIsUntransformedUponFullTurn(of angle: Angle) {
      #expect(Complex(2, 4).u1(by: angle).isApproximatelyEqual(to: Complex(2, 4)))
    }

    @Test func fieldIsTransformedWhenRotatedByNonGroupIdentity() {
      #expect(
        Complex(2, 4).u1(by: .radians(2)).isApproximatelyEqual(
          to: Complex(-4.46, 0.15),
          relativeTolerance: 0.01
        )
      )
    }
  }
}
