//
//  Anti+ColorTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 13/06/25.
//

import Testing

@testable import StandardKit

struct AnticolorTests {
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
