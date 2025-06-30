//
//  RandomAccessCollection+Chunk.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.28.
//

extension RandomAccessCollection where Index: BinaryInteger, Index.Stride: SignedInteger {
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
  ///   Sizing               | Result                |
  ///   -------------------- | --------------------- |
  ///   `size` ≤ 0           | `[]`                  |
  ///   `size` ≥ `count`     | `[self[...]]`         |
  ///   0 < `size` < `count` | ≤-`size`-sized chunks |
  func chunked(into size: Int, allowsPartiality: Bool = true) -> [SubSequence] {
    guard !isEmpty && size > 0 else { return [] }
    guard size < count else { return [self[...]] }
    let partiality = allowsPartiality && count % size > 0 ? 1 : 0
    let chunkCount = count / size + partiality
    return [SubSequence](
      unsafeUninitializedCapacity: chunkCount,
      initializingWith: { buffer, initializedCount in
        guard var addressOfCurrentChunk = buffer.baseAddress else { return }
        var currentChunk = self[startIndex...startIndex.advanced(by: size - 1)]
        let indexOfLastChunk = startIndex + Index(chunkCount - 1)
        for indexOfCurrentChunk in startIndex...indexOfLastChunk {
          addressOfCurrentChunk.initialize(to: currentChunk)
          guard indexOfCurrentChunk < indexOfLastChunk else { break }
          addressOfCurrentChunk = addressOfCurrentChunk.successor()
          currentChunk =
            self[
              currentChunk.endIndex..<Swift.min(endIndex, currentChunk.endIndex.advanced(by: size))
            ]
        }
        initializedCount = chunkCount
      }
    )
  }
}
