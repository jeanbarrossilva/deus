//
//  ColorsTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.20.
//

import Testing

@testable import StandardKit

struct ColorsTests {
  @Suite("Combination") struct CombinationTests {
    @Test func redPlusRedIsRed() {
      #expect(Pigment.red + .red == .red)
    }

    @Test func redPlusGreenIsBrown() {
      #expect(Pigment.red + .green == .brown)
    }

    @Test func redPlusBlueIsPurple() {
      #expect(Pigment.red + .blue == .purple)
    }

    @Test func greenPlusBlueIsCyan() {
      #expect(Pigment.green + .blue == .cyan)
    }

    @Test(arguments: Pigment.allCases) func whitePlusColorIsColor(_ color: Pigment) {
      #expect(Mixture.white + color == .of(color))
    }

    @Test(
      arguments: zip(
        [Mixture.brown, .purple, .cyan].spread(by: { _ in 2 }),
        [Pigment.red, .green, .red, .blue, .green, .blue]
      )
    )
    func twoColorMixturePlusOneOfItsColorsIsTheMixtureItself(_ mixture: Mixture, _ color: Pigment) {
      #expect(mixture + color == mixture)
    }
  }

  @Test func obtainsMixtureOfRed() {
    #expect(Mixture.of(.red) == .red)
  }

  @Test func obtainsMixtureOfGreen() {
    #expect(Mixture.of(.green) == .green)
  }

  @Test func obtainsMixtureOfBlue() {
    #expect(Mixture.of(.blue) == .blue)
  }
}
