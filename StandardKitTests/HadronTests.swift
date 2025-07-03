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
      @Test("u + d̄ → π⁺")
      func resultsFromCombiningAnUpQuarkAndADownAntiquark() {
        let upQuark = UpQuark(color: red)
        let downAntiquark = Anti(DownQuark(color: red))
        let positivePion = upQuark + downAntiquark
        #expect(positivePion.quarks[0].isPartiallyEqual(to: upQuark))
        #expect(positivePion.quarks[1].isPartiallyEqual(to: downAntiquark))
      }

      @Test
      func chargeIsOneE() {
        #expect((UpQuark(color: red) + Anti(DownQuark(color: red))).charge == .elementary(1))
      }
    }
  }
}
