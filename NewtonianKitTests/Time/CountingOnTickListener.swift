//
//  CountingOnTickListener.swift
//  Deus
//
//  Created by Jean Barros Silva on 29/04/25.
//

@testable import NewtonianKit

/// ``Clock.OnTickListener`` which counts the amount of times it has been notified of ticks.
///
/// - SeeAlso: ``count``
struct CountingOnTickListener: OnTickListener {
  /// Amount of times ticks have been notified to this ``CountingOnTicklistener``.
  var count = 0

  mutating func onTick() async {
    count += 1
  }
}
