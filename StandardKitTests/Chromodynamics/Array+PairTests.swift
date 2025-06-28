//
//  Array+PairsTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.25.
//

import Testing

@testable import StandardKit

struct ArrayPairTests {
  @Suite("Interchangeable match") struct InterchangeableMatchTests {
    @Test(arguments: [[], [2]]) func doesNotTestWhenThereAreNoPairs(_ pairs: [Int]) {
      var testCount = 0
      let _ = pairs.either { _, _ in
        testCount += 1
        return true
      }
      #expect(testCount == 0)
    }

    @Test(arguments: [[2, 4], [2, 4, 8, 12]])
    func testsEachPairInBothNormalAndInterchangedOrdersWhenNoneMatchesThePredicate(_ pairs: [Int]) {
      let targetCount = pairs.count * 2
      let targets =
        [Int](
          unsafeUninitializedCapacity: targetCount,
          initializingWith: { buffer, initializedCount in
            guard let baseAddress = buffer.baseAddress else { return }
            var index = 0
            let _ = pairs.either { first, second in
              baseAddress.advanced(by: index).initialize(to: first)
              index += 1
              baseAddress.advanced(by: index).initialize(to: second)
              index += 1
              return false
            }
            initializedCount = targetCount
          }
        )
      #expect(
        targets
          == pairs
          .windowed(in: 2, allowsPartiality: false)
          .paired(to: { pair in pair.reversed() })
          .joined()
          .map(\.self)
      )
    }

    @Test func returnsWhenPairMatchesThePredicate() {
      var testCount = 0
      let containsPredicateMatchingPair = [2, 4, 8, 12].either({ first, second in
        testCount += 1
        return first == 8 && second == 12
      })
      #expect(testCount == 3)
      #expect(containsPredicateMatchingPair)
    }
  }

  @Suite("Pairing") struct PairingTests {
    @Test func pairingOnAnEmptyArrayReturnsAnEmptyArray() {
      #expect([Int]().paired(to: { n in n }) == [])
    }

    @Test func pairsElementsToThoseOfAPopulatedArray() {
      #expect([2, 4].paired(to: { n in n + 1 }) == [2, 3, 4, 5])
    }
  }
}
