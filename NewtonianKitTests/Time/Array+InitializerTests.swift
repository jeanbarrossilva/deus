//
//  Array+InitializerTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 03/05/25.
//

import Foundation
import Testing

struct ArrayInitializerTests {
  @Test func isEmptyWhenCountIsNegative() throws {
    #expect([Int](count: -2) { index in index }.isEmpty)
  }

  @Test func elementsAreNotInitializedWhenCountIsNegative() throws {
    var elementInitializationCount = 0
    let _ = [Int](count: -2) { index in
      elementInitializationCount += 1
      return index
    }
    #expect(elementInitializationCount == 0)
  }

  @Test func callsElementInitializerAsManyTimesAsSpecified() throws {
    var elementInitializerCallCount = 0
    let _ = [Int](count: 2) { index in
      elementInitializerCallCount += 1
      return index
    }
    #expect(elementInitializerCallCount == 2)
  }

  @Test func containsAsManyElementsAsSpecified() throws {
    #expect([Int](count: 2) { index in index }.count == 2)
  }

  @Test func elementsAreReferentiallyEqualToInitializedOnes() throws {
    var initializedElements = [NSObject?](repeating: nil, count: 2)
    let initializerBasedElements =
      [NSObject](count: 2) { index in
        let element = NSObject()
        initializedElements[index] = element
        return element
      }
    for (index, element) in initializerBasedElements.enumerated() {
      #expect(element === initializedElements[index])
    }
  }
}
