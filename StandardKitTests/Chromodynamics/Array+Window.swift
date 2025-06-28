//
//  Array+Window.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.28.
//

extension Array {
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
  func windowed(in size: Int, allowsPartiality: Bool) -> [Self] {
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
