//
//  Collection+RepetitionTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.29.
//

import Testing

struct CollectionRepetitionTests {
  @Suite("Spreading") struct SpreadingTests {
    @Test func spreadingEmptyCollectionReturnsEmptyArray() {
      #expect([Int]().spread(by: { _ in 2 }) == [])
    }

    @Test func spreadingPopulatedCollectionToOneReturnsTheCollectionItself() {
      #expect([2, 4].spread(by: { _ in 1 }) == [2, 4])
    }

    @Test func spreadsPopulatedCollectionToMany() {
      #expect([2, 4].spread(by: { n in n }) == [2, 2, 4, 4, 4, 4])
    }
  }
}
