//
//  Array+SliceTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 03/05/25.
//

import Testing

struct ArraySliceTests {
  @Test func returnsEmptyArrayWhenSlicingWithoutIndices() throws {
    #expect([0, 1, 2, 3].sliced(0..<0).isEmpty)
  }

  @Test func returnsOriginalArrayWhenSlicingWithIndicesEqualToItsOwn() throws {
    let elements = [0, 1, 2, 3]
    #expect(elements.sliced(0..<4) == elements)
  }

  @Test func slices() throws {
    #expect([0, 1, 2, 3].sliced(1..<3) == [1, 2])
  }
}
