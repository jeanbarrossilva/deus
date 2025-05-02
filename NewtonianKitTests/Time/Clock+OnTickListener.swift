//
//  Clock+OnTickListener.swift
//  Deus
//
//  Created by Jean Barros Silva on 01/05/25.
//

import Foundation

@testable import NewtonianKit

extension Clock {
  /// Adds the returned ``OnTickListener``s ``count`` times to this ``Clock``.
  ///
  /// - Parameters:
  ///   - initializer: Produces one of the ``OnTickListener``s to be added.
  ///   - count: Amount of times the ``initializer`` will be called and its results will be added.
  /// - SeeAlso: ``Clock.add(onTickListener:)``
  func addOnTickListener<O: OnTickListener>(initializer: () -> O, count: Int) async -> [UUID] {
    var ids = [UUID?](repeating: nil, count: count)
    for index in ids.indices {
      let id = add(onTickListener: initializer())
      ids.insert(id, at: index)
    }
    return ids as! [UUID]
  }
}
