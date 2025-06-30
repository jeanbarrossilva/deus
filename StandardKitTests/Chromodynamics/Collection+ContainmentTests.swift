//
//  Collection+ContainmentTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.21.
//

import Testing

@testable import StandardKit

@Suite("Collection+Containment tests") struct CollectionContainmentTests {
  @Test func testsWhetherContainsOnlyAnElementWhenItDoes() {
    #expect([2, 2].contains(only: 2))
  }

  @Test func testsWhetherContainsOnlyAnElementWhenItDoesNot() {
    #expect(![2, 4].contains(only: 2))
  }
}
