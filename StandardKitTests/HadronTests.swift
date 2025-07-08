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
import Testing

@testable import StandardKit

@Suite("Hadron tests")
struct HadronTests {
  @Suite("Pion")
  struct PionTests {
    @Suite("π⁺")
    struct PositiveTests {
      private let upQuark = UpQuark(color: red)
      private let downAntiquark = Anti(DownQuark(color: red))
      private lazy var positivePion = upQuark + downAntiquark

      @Test("u + d̄ → π⁺")
      mutating func resultsFromCombiningAnUpQuarkAndADownAntiquark() {
        #expect(positivePion.quarks[0].isPartiallyEqual(to: upQuark))
        #expect(positivePion.quarks[1].isPartiallyEqual(to: downAntiquark))
      }

      @Test
      mutating func chargeIsOneE() {
        #expect(
          (UpQuark(color: red) + Anti(DownQuark(color: red))).charge
            == Measurement(value: 1, unit: .elementary)
        )
      }
    }

    @Suite("π⁻")
    struct NegativeTests {
      private let downQuark = DownQuark(color: red)
      private let upAntiquark = Anti(UpQuark(color: red))
      private lazy var negativePion = downQuark + upAntiquark

      @Test("d + ū → π⁻")
      mutating func resultsFromCombiningADownQuarkAndAnUpAntiquark() {
        #expect(negativePion.quarks[0].isPartiallyEqual(to: downQuark))
        #expect(negativePion.quarks[1].isPartiallyEqual(to: upAntiquark))
      }

      @Test
      mutating func chargeIsNegativeOneE() {
        #expect(negativePion.charge == Measurement(value: -1, unit: .elementary))
      }
    }
  }
}
