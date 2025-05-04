//
//  Array+TransformTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 02/05/25.
//

import Testing

@testable import NewtonianKit

struct ArrayTransformTests {
  @Test func transformsBasedOnEachElement() async throws {
    let unmappedElements = [CountingOnTickListener](count: 2) { _ in CountingOnTickListener() }
    let mappedElements = await unmappedElements.map { listener in listener }
    for (index, onTickListener) in mappedElements.enumerated() {
      #expect(onTickListener === unmappedElements[index])
    }
  }

  @Test func transforms() async throws {
    #expect(await [2, 4].map { element in element * element } == [4, 16])
  }
}
