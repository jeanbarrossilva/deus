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
  /// Pairs each element of this `Array` to a respective value.
  ///
  /// - Parameter pair: Produces the value to be paired to the given element in the returned
  ///   `Array`.
  fileprivate func paired(to pair: (Element) throws -> Element) rethrows -> Self {
    guard !isEmpty else { return [] }
    let pairedCount = count * 2
    return try Self.init(
      unsafeUninitializedCapacity: pairedCount,
      initializingWith: { buffer, initializedCount in
        var index = 0
        for element in self {
          guard let baseAddress = buffer.baseAddress else { break }
          baseAddress.advanced(by: index).initialize(to: element)
          index += 1
          baseAddress.advanced(by: index).initialize(to: try pair(element))
          index += 1
        }
        initializedCount = pairedCount
      }
    )
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
  ///   Condition            | Result                                                        |
  ///   -------------------- | ------------------------------------------------------------- |
  ///   `size` ≤ 0           | An empty `Array`                                              |
  ///   `size` ≥ `count`     | An `Array` containing this `Array`                            |
  ///   0 ≤ `size` < `count` | The elements of this `Array` divided into groups of such size |
  fileprivate func windowed(in size: Int, allowsPartiality: Bool) -> [Self] {
    guard !isEmpty && size > 0 else { return [] }
    guard size < count else { return [self] }
    let partiality = allowsPartiality ? count % size : 0
    let windowCount = count / size + partiality
    return [Self](
      unsafeUninitializedCapacity: windowCount,
      initializingWith: { buffer, initializedCount in
        var currentWindow =
          Self.init(unsafeUninitializedCapacity: size, initializingWith: { _, _ in })
        var currentWindowIndex = 0

        // reserveCapacity(_:) may reserve a capacity greater than that which was requested. This
        // variable stores the actual, ungrown amount of elements known to be contained in the
        // window by the end of the iteration.
        var currentWindowUngrownCapacity = currentWindow.capacity

        for (elementIndex, element) in enumerated() {
          currentWindow.append(element)
          guard currentWindow.count == currentWindowUngrownCapacity else { continue }
          guard let baseAddress = buffer.baseAddress else { break }
          baseAddress.advanced(by: currentWindowIndex).initialize(to: currentWindow)
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
}
