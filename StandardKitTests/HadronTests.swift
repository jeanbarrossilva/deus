//
//  HadronTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.07.01.
//

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
        #expect((UpQuark(color: red) + Anti(DownQuark(color: red))).charge == .elementary(1))
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
        #expect(negativePion.charge == .elementary(-1))
      }
    }
  }
}
