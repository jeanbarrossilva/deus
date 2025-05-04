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
    guard bounds != self.indices else { return self }
    guard !bounds.isEmpty else { return [] }
    guard bounds.count > 1 else { return [self[bounds.lowerBound]] }
    var bounds = bounds.map { bound in bound }
    while bounds.endIndex > endIndex { let _ = bounds.popLast() }
    return .init(count: bounds.count) { index in self[bounds[index]] }
  }
}
