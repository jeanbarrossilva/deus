//
//  Collection+PairTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.25.
//

import Testing

@Suite("Collection+Pair tests") struct CollectionPairTests {
  @Suite("Pairing") struct PairingTests {
    @Test func pairingOnAnEmptyArrayReturnsAnEmptyArray() {
      #expect([Int]().paired(to: { n in n }) == [])
    }

    @Test func pairsElementsToThoseOfAPopulatedArray() {
      #expect([2, 4].paired(to: { n in n + 1 }) == [2, 3, 4, 5])
    }
  }
}
