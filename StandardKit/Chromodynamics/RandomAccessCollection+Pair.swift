//
//  RandomAccessCollection+Pairs.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.25.
//

extension RandomAccessCollection {
  /// Returns whether all pairs of elements of this `Array` match the `predicate` in some order.
  ///
  /// - Parameter predicate: Condition to be satisfied, given a pair of elements (*a*, *b*). If it
  ///   is unsatisfied when *a* and *b* of the pair are passed in respectively, this closure is
  ///   called again with the pair switched (*b*, *a*).
  /// - Returns: `true` in case this `Array` does not contain enough elements to form a pair
  ///   (`count` < 2) or the `predicate` was satisfied by all pairs of elements in either order;
  ///   otherwise, `false`.
  func either(_ predicate: (_ first: Element, _ second: Element) throws -> Bool) rethrows -> Bool {
    guard !isEmpty else { return true }
    var firstIndex = startIndex
    var secondIndex = index(firstIndex, offsetBy: 1)
    while secondIndex < endIndex {
      let first = self[firstIndex]
      let second = self[secondIndex]
      guard try !predicate(first, second) && !predicate(second, first) else { return true }
      firstIndex = index(firstIndex, offsetBy: 2)
      secondIndex = index(secondIndex, offsetBy: 2)
    }
    return false
  }
}
