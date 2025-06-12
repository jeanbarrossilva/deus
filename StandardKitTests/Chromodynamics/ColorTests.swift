//
//  ColorTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 11/06/25.
//

import Testing

@testable import StandardKit

struct ColorTests {
  @Test(arguments: Color.allCases) func anticolorHasCounterpart(color: Color) {
    #expect(Anti(color).counterpart == color)
  }
}
