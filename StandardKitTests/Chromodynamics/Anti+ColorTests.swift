//
//  Anti+ColorTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 13/06/25.
//

import Testing

@testable import StandardKit

struct AnticolorTests {
  @Suite("Combination") struct CombinationTests {
    @Test func redPlusAntiredIsWhite() {
      #expect(Pigment.red + .anti(.red) == .white)
    }

    @Test func greenPlusAntigreenIsWhite() {
      #expect(Pigment.green + .anti(.green) == .white)
    }

    @Test func bluePlusAntiblueIsWhite() {
      #expect(Pigment.blue + .anti(.blue) == .white)
    }
  }

  @Test(arguments: Pigment.allCases) func anticolorHasCounterpart(color: Pigment) {
    #expect(Anti(color).counterpart == color)
  }
}
