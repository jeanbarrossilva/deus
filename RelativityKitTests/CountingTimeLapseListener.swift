//
//  CountingTimeLapseListener.swift
//  Deus
//
//  Created by Jean Barros Silva on 29/04/25.
//

import Foundation

@testable import RelativityKit

/// ``Clock.TimeLapseListener`` which counts the amount of times it has been notified of ticks.
///
/// - SeeAlso: ``count``
final class CountingTimeLapseListener: TimeLapseListener {
  /// Amount of times ticks have been notified to this ``CountingTimeLapseListener``.
  private(set) var count = 0

  func timeDidElapse(
    from start: Duration,
    after previous: Duration?,
    to current: Duration,
    toward end: Duration
  ) async {
    count += 1
  }
}
