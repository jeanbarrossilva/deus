//
//  Array+SliceTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 03/05/25.
//

import Foundation
import Testing

struct ArraySliceTests {
  @Test func returnsEmptyArrayWhenSlicingWithoutIndices() throws {
    #expect([0, 1, 2, 3].sliced(0..<0).isEmpty)
  }

  @Test func returnsOriginalSingleElementArrayWhenSlicingWithIndicesEqualToItsOwn() throws {
    let elements = [NSObject()]
    let slice = elements.sliced(0..<1)
    #expect(slice.count == 1)
    #expect(slice[0] === elements[0])
  }

  @Test func returnsOriginalMultiElementArrayWhenSlicingWithIndicesEqualToItsOwn() throws {
    let elements = [NSObject](count: 4) { _ in NSObject() }
    let slice = elements.sliced(0..<5)
    #expect(slice.count == 4)
    for (index, element) in slice.enumerated() { #expect(element === elements[index]) }
  }

  @Test func slices() throws {
    #expect([0, 1, 2, 3].sliced(1..<3) == [1, 2])
  }
}
