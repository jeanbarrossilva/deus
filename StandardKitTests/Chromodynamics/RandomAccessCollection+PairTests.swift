//
//  RandomAccessCollection+PairTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.30.
//

import Testing

@testable import StandardKit

@Suite("RandomAccessCollection+Pair tests") struct RandomAccessCollectionPairTests {
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
          .chunked(into: 2, allowsPartiality: false)
          .paired(to: { pair in
            var reversed = ArraySlice(pair)
            reversed.reverse()
            return reversed
          })
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
}
