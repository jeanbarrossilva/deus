//
//  CountingOnTickListener.swift
//  Deus
//
//  Created by Jean Barros Silva on 29/04/25.
//

import Foundation

@testable import NewtonianKit

/// ``Clock.OnTickListener`` which counts the amount of times it has been notified of ticks.
///
/// - SeeAlso: ``count``
final class CountingOnTickListener: OnTickListener {
  /// Amount of times ticks have been notified to this ``CountingOnTicklistener``.
  private(set) var count = 0

  func onTick() async {
    count += 1
  }
}
