//
//  Array+TransformTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 02/05/25.
//

import Foundation
import Testing

struct ArrayTransformTests {
  @Test func transformsBasedOnEachElement() async throws {
    let unmappedElements = [NSObject](count: 2) { _ in NSObject() }
    let mappedElements = await unmappedElements.map { listener in listener }
    for (index, mappedElement) in mappedElements.enumerated() {
      #expect(mappedElement === unmappedElements[index])
    }
  }

  @Test func transforms() async throws {
    #expect(await [2, 4].map { element in element * element } == [4, 16])
  }
}
