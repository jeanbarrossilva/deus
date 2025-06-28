//
//  Array+Pair.test.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.28.
//

extension Array {
  /// Pairs each element of this `Array` to a respective value.
  ///
  /// - Parameter pair: Produces the value to be paired to the given element in the returned
  ///   `Array`.
  func paired(to pair: (Element) throws -> Element) rethrows -> Self {
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
}
