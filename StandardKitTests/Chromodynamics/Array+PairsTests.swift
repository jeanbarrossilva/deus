//
//  Array+PairsTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.25.
//

import Testing

@testable import StandardKit

struct ArrayPairsTests {
  @Suite("Interchangeable match") struct InterchangeableMatchTests {
    @Test(arguments: [[], [2]]) func doesNotTestWhenThereAreNoPairs(_ pairs: [Int]) {
      var testCount = 0
      let _ = pairs.either { _, _ in
        testCount += 1
        return true
      }
      #expect(testCount == 0)
    }

    @Test(arguments: [[2, 4], [2, 4, 8, 16]])
    func testsEachPairInBothNormalAndInterchangedOrdersWhenNoneMatchesThePredicate(_ pairs: [Int]) {
      var targets = [Int](unsafeUninitializedCapacity: 4, initializingWith: { _, _ in })
      let _ = pairs.either { first, second in
        targets.append(first)
        targets.append(second)
        return false
      }
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
      let containsPredicateMatchingPair = [2, 4, 8, 16].either({ first, second in
        testCount += 1
        return first == 8 && second == 16
      })
      #expect(testCount == 3)
      #expect(containsPredicateMatchingPair)
    }
  }
}

extension Array {
  /// Pairs each element of this `Array` to a respective one.
  ///
  /// - Parameter pair: Produces the element to be paired to the given one in the returned `Array`.
  fileprivate func paired(to pair: (Element) throws -> Element) rethrows -> Self {
    guard !isEmpty else { return [] }
    var pairs = Self.init(unsafeUninitializedCapacity: count * 2)
    for element in self {
      pairs.append(element)
      pairs.append(try pair(element))
    }
    return pairs
  }

  /// Groups elements of this `Array` into `Array`s with the specified amount of elements (windows).
  ///
  /// - Parameters:
  ///   - size: Quantity in which the elements will be grouped.
  ///   - allowsPartiality: Whether the last window can contain less than `size` elements due to the
  ///     `Array` on which this function is called containing an amount of elements insufficient for
  ///     such size. When `false`, remaining elements will be ignored.
  ///
  ///     E.g., given `self` = `[2, 4, 8, 12, 16]` and `size` = 2:
  ///
  ///     `allowsPartiality` | Result                    |
  ///     ------------------ | ------------------------- |
  ///     `false`            | `[[2, 4], [8, 12]]`       |
  ///     `true`             | `[[2, 4], [8, 12], [16]]` |
  /// - Returns:
  ///   Condition            | Result
  ///   -------------------- | ------
  ///   `size` ≤ 0           | An empty `Array`
  ///   `size` > `count`     | An `Array` containing this `Array`
  ///   0 ≤ `size` < `count` | The elements of this `Array` divided into groups of such size
  fileprivate func windowed(in size: Int, allowsPartiality: Bool) -> [Self] {
    guard !isEmpty && size > 0 else { return [] }
    guard size < count else { return [self] }
    let partiality = allowsPartiality ? count % size : 0
    let windowCount = count / size + partiality
    return [Self](
      unsafeUninitializedCapacity: windowCount,
      initializingWith: { buffer, initializedCount in
        var currentWindow = Self.init(unsafeUninitializedCapacity: size)
        var currentWindowIndex = 0

        // reserveCapacity(_:) may reserve a capacity greater than that which was requested. This
        // variable stores the actual, ungrown amount of elements known to be contained in the
        // window by the end of the iteration.
        var currentWindowUngrownCapacity = currentWindow.capacity

        for (elementIndex, element) in enumerated() {
          currentWindow.append(element)
          guard currentWindow.count == currentWindowUngrownCapacity else { continue }
          buffer.baseAddress?.advanced(by: currentWindowIndex).initialize(to: currentWindow)
          currentWindow.removeAll(keepingCapacity: true)
          currentWindowIndex += 1
          currentWindowUngrownCapacity =
            allowsPartiality && distance(from: elementIndex + 1, to: endIndex) < size
            ? partiality
            : size
          currentWindow.reserveCapacity(currentWindowUngrownCapacity)
        }
        initializedCount = windowCount
      }
    )
  }

  /// Creates an `Array` of a specific capacity, whose elements are uninitialized.
  ///
  /// - Parameter unsafeUninitializedCapacity: Amount of elements for which space will be allocated
  ///   preemptively.
  private init(unsafeUninitializedCapacity: Int) {
    self =
      .init(unsafeUninitializedCapacity: unsafeUninitializedCapacity, initializingWith: { _, _ in })
  }
}
