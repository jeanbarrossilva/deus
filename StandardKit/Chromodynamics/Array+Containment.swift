//
//  Array+Containment.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.21.
//

extension Array where Element: Equatable {
  /// Returns whether all elements are structurally equal to the given one.
  ///
  /// ## Semantics
  ///
  /// Shorthand for `allSatisfy { $0 == candidate }`.
  ///
  /// - Parameter candidate: Element to which each of the ones in this `Array` will be compared.
  /// - Returns: `true` in case all elements equal to the `candidate` structurally; otherwise,
  ///   `false`.
  func contains(only candidate: Element) -> Bool {
    for element in self {
      guard element == candidate else { return false }
      continue
    }
    return true
  }
}
