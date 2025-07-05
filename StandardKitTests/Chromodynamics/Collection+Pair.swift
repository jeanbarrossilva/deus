//
//  Collection+Pair.test.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.28.
//

extension Collection {
  /// Pairs each element of this `Collection` to a respective value.
  ///
  /// - Parameter pair: Produces the pair of the given element.
  /// - Returns: An `Array` with the produced pairs joined to each existing element of this
  ///   `Collection`.
  func paired(to pair: (Element) throws -> Element) rethrows -> [Element] {
    guard !isEmpty else { return self as? [Element] ?? [] }
    let pairedCount = count * 2
    return try [Element](
      unsafeUninitializedCapacity: pairedCount,
      initializingWith: { buffer, initializedCount in
        guard var currentAddress = buffer.baseAddress else { return }
        for (index, element) in zip(indices, self) {
          currentAddress.initialize(to: element)
          currentAddress = currentAddress.successor()
          currentAddress.initialize(to: try pair(element))
          guard index < endIndex else { break }
          currentAddress = currentAddress.successor()
        }
        initializedCount = pairedCount
      }
    )
  }
}
