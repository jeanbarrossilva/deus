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
      #expect(Color.red + .anti(.red) == .white)
    }

    @Test func greenPlusAntigreenIsWhite() {
      #expect(Color.green + .anti(.green) == .white)
    }

    @Test func bluePlusAntiblueIsWhite() {
      #expect(Color.blue + .anti(.blue) == .white)
    }
  }

  @Test(arguments: Color.allCases) func anticolorHasCounterpart(color: Color) {
    #expect(Anti(color).counterpart == color)
  }
}
