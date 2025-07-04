//
//  ColorTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.20.
//

import Testing

@testable import StandardKit

struct ColorTests {
  @Suite("Combination")
  struct CombinationTests {
    @Suite("Idempotent")
    struct IdempotentTests {
      @Test
      func redPlusRedIsRed() {
        #expect(red + red == .red)
      }

      @Test
      func greenPlusGreenIsGreen() {
        #expect(green + green == .green)
      }

      @Test
      func bluePlusBlueIsBlue() {
        #expect(blue + blue == .blue)
      }
    }

    @Suite("Differential")
    struct DifferentialTests {
      @Test func redPlusGreenIsBrown() {
        #expect(red + green == .brown)
      }

      @Test func redPlusBlueIsPurple() {
        #expect(red + blue == .purple)
      }

      @Test func greenPlusBlueIsCyan() {
        #expect(green + blue == .cyan)
      }
    }

    @Test
    func whitePlusRedIsRed() {
      #expect(Mixture.white + red == .red)
    }

    @Test
    func whitePlusGreenIsGreen() {
      #expect(Mixture.white + green == .green)
    }

    @Test
    func whitePlusBlueIsBlue() {
      #expect(Mixture.white + blue == .blue)
    }
  }

  @Test
  func obtainsMixtureOfRed() {
    #expect(Mixture.of(red) == .red)
  }

  @Test
  func obtainsMixtureOfGreen() {
    #expect(Mixture.of(green) == .green)
  }

  @Test
  func obtainsMixtureOfBlue() {
    #expect(Mixture.of(blue) == .blue)
  }
}
