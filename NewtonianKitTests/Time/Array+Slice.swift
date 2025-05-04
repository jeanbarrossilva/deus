//
//  Array+Slice.swift
//  Deus
//
//  Created by Jean Barros Silva on 03/05/25.
//

extension Array {
  /// Produces an ``Array`` containing the elements at the given ``indices`` of this one.
  ///
  /// - Parameter indices: Indices of this ``Array`` at which the elements to be copied into the
  ///   produced one are.
  /// - Returns: Another ``Array`` with `indices.count` elements of this one, or this one itself in
  ///   case the specified ``indices`` equal to those of this ``Array``.
  func sliced(_ bounds: Range<Index>) -> [Element] {
    if bounds.isEmpty {
      return []
    } else if bounds.count == 1 {
      return [self[bounds.lowerBound]]
    } else if bounds == self.indices {
      return self
    } else {
      let sequencedBounds = bounds.map { bound in bound }
      return .init(count: sequencedBounds.count) { index in self[sequencedBounds[index]] }
    }
  }
}
