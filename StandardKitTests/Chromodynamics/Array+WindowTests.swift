//
//  Array+WindowTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.28.
//

import Testing

struct ArrayWindowTests {
  @Test(arguments: [false, true])
  func windowingAnEmptyArrayReturnsAnEmptyArray(allowsPartiality: Bool) {
    #expect([Int]().windowed(in: 2, allowsPartiality: allowsPartiality) == [])
  }

  @Test(arguments: [0, -2], [false, true])
  func windowingWithAZeroedOrNegativeSizeReturnsAnEmptyArray(size: Int, allowsPartiality: Bool) {
    #expect([2, 4].windowed(in: size, allowsPartiality: allowsPartiality) == [])
  }

  @Test(arguments: [2, 4], [false, true])
  func windowingWithASizeEqualToOrGreaterThanTheCountReturnsAnArrayWhoseOnlyElementIsTheArrayItself(
    size: Int,
    allowsPartiality: Bool
  ) {
    #expect([2, 4].windowed(in: size, allowsPartiality: allowsPartiality) == [[2, 4]])
  }

  @Test(arguments: [false, true]) func windowsImpartially(allowsPartiality: Bool) {
    #expect(
      [2, 4, 8, 12].windowed(in: 2, allowsPartiality: allowsPartiality) == [[2, 4], [8, 12]])
  }

  @Test func windowsPartially() {
    #expect(
      [2, 4, 8, 12, 16].windowed(in: 2, allowsPartiality: true) == [[2, 4], [8, 12], [16]]
    )
  }
}
