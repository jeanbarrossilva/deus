//
//  Anti+ColorTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 13/06/25.
//

import Testing

@testable import StandardKit

struct AnticolorTests {
  @Suite("Combination")
  struct CombinationTests {
    @Test("r + r̄ = white")
    func redPlusAntiredIsWhite() {
      #expect(red + Anti(red) == .white)
    }

    @Test("g + ḡ = white")
    func greenPlusAntigreenIsWhite() {
      #expect(green + Anti(green) == .white)
    }

    @Test("b + b̄ = white")
    func bluePlusAntiblueIsWhite() {
      #expect(blue + Anti(blue) == .white)
    }
  }

  @Test
  func redIsCounterpartOfAntired() {
    #expect(Anti(red).counterpart === red)
  }

  @Test
  func greenIsCounterpartOfAntigreen() {
    #expect(Anti(green).counterpart === green)
  }

  @Test
  func blueIsCounterpartOfAntiblue() {
    #expect(Anti(blue).counterpart === blue)
  }
}
