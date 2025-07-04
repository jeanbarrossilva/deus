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
// not, see https://www.gnu.org/licenses.</string>
// ===-------------------------------------------------------------------------------------------===

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
