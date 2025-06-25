//
//  ColorTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 11/06/25.
//

import Testing

@testable import StandardKit

struct ColorTests {
  @Test func redPlusRedIsRed() {
    #expect(Color.red + .red == .red)
  }

  @Test func redPlusGreenIsBrown() {
    #expect(Color.red + .green == .brown)
  }

  @Test func redPlusBlueIsPurple() {
    #expect(Color.red + .blue == .purple)
  }

  @Test func greenPlusBlueIsCyan() {
    #expect(Color.green + .blue == .cyan)
  }
}
