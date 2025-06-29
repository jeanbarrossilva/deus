//
//  Collection+Chunk.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.28.
//

extension Collection {
  /// Divides this `Collection` into chunks of `size`.
  ///
  /// ## Difference from that of swift-algorithms
  ///
  /// The swift-algorithms package, as of 1.2.1, provides an extension function for dividing a
  /// `Collection` into chunks: `chunks(ofCount:)`. Our implementation, however, provides control
  /// over whether partiality is allowed or prohibited; in contrast, `chunks(ofCount:)` presupposes
  /// that partiality is always permitted, never ignoring the last chunk when its size is greater
  /// than that which has been specified.
  ///
  /// Apart from this distinction, and although some optimazations are not present here (such as
  /// lazy chunk evaluation), the contents of the return value of both functions are the same.
  ///
  /// - Parameters:
  ///   - size: Quantity in which the elements will be grouped.
  ///   - allowsPartiality: Whether the last chunk can contain less than `size` elements due to the
  ///     `count` of this `Collection` being insufficient for a division into such size. When
  ///     `false`, remaining elements will be ignored.
  ///
  ///     E.g., given `self` = `[2, 4, 8, 12, 16]` and `size` = 2:
  ///
  ///     `allowsPartiality` | Result                    |
  ///     ------------------ | ------------------------- |
  ///     `false`            | `[[2, 4], [8, 12]]`       |
  ///     `true`             | `[[2, 4], [8, 12], [16]]` |
  /// - Returns:
  ///   Sizing               | Result          |
  ///   -------------------- | --------------- |
  ///   `size` ≤ 0           | `[]`            |
  ///   `size` ≥ `count`     | `[self]`        |
  ///   0 < `size` < `count` | ≤ `size` chunks |
  func chunked(into size: Int, allowsPartiality: Bool = true) -> [[Element]] {
    guard !isEmpty && size > 0 else { return [] }
    guard size < count else { return [self as? [Element] ?? map(\.self)] }
    let partiality = allowsPartiality ? count % size : 0
    let windowCount = count / size + partiality
    return [[Element]](
      unsafeUninitializedCapacity: windowCount,
      initializingWith: { buffer, initializedCount in
        var currentWindow =
          [Element](unsafeUninitializedCapacity: size, initializingWith: { _, _ in })
        var currentWindowIndex = 0

        // reserveCapacity(_:) may reserve a capacity greater than that which was requested. This
        // variable stores the actual, ungrown amount of elements known to be contained in the
        // window by the end of the iteration.
        var currentWindowUngrownCapacity = currentWindow.capacity

        for (elementIndex, element) in zip(indices, self) {
          currentWindow.append(element)
          guard currentWindow.count == currentWindowUngrownCapacity else { continue }
          guard let baseAddress = buffer.baseAddress else { break }
          baseAddress.advanced(by: currentWindowIndex).initialize(to: currentWindow)
          currentWindow.removeAll(keepingCapacity: true)
          currentWindowIndex += 1
          currentWindowUngrownCapacity =
            allowsPartiality && distance(from: index(after: elementIndex), to: endIndex) < size
            ? partiality
            : size
          currentWindow.reserveCapacity(currentWindowUngrownCapacity)
        }
        initializedCount = windowCount
      }
    )
  }
}
