//
//  Array+Transform.swift
//  Deus
//
//  Created by Jean Barros Silva on 02/05/25.
//

@testable import NewtonianKit

extension Array {
  /// Produces an ``Array`` containing the result of having applied the given transformation to each
  /// element of this ``Array``. Differs from the one in the standard library in that it is
  /// asynchronous and, thus, allows for asynchronous transformations.
  ///
  /// - Parameter transform: Transformation to be performed to an element contained in this
  ///   ``Array``.
  /// - Returns: The transformations made to each element.
  func map<R>(_ transform: (_ listener: Element) async throws -> R) async rethrows -> [R] {
    var results = [R?](count: count) { _ in nil }
    for index in indices { results[index] = try await transform(self[index]) }
    return results as! [R]
  }
}
