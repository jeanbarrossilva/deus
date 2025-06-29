//
//  Collection+Repetition.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.29.
//

extension Collection {
  /// Makes an `Array` in which each element of this one is repeated consecutively by the specified
  /// amount of times.
  ///
  /// - Parameter count: Determines the amount of times the given element will be repeated in the
  ///   returned `Array`.
  func spread(by: (Element) throws -> Int) rethrows -> [Element] {
    guard !isEmpty else { return self as? [Element] ?? map(\.self) }
    let counts = try map(by)
    let spreadCount = counts.reduce(0, +)
    guard spreadCount != self.count else { return self as? [Element] ?? map(\.self) }
    guard spreadCount > 0 else { return [] }
    return [Element](
      unsafeUninitializedCapacity: spreadCount,
      initializingWith: { buffer, initializedCount in
        var offset = 0
        for (index, element) in enumerated() {
          guard let baseAddress = buffer.baseAddress else { break }
          for _ in 1...counts[index] {
            baseAddress.advanced(by: offset).initialize(to: element)
            offset += 1
          }
        }
        initializedCount = spreadCount
      }
    )
  }
}
