//
//  Clock+OnTickListenerTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 01/05/25.
//

import Testing

@testable import NewtonianKit

struct ClockPlusOnTicklistenerTests {
  private var subticker = VirtualSubticker()
  private var clock: Clock { Clock(subticker: subticker) }

  @Test func addsOnTickListeners() async throws {
    let onTickListenerIDs = await clock.addOnTickListener(
      initializer: { CountingOnTickListener() },
      count: 2
    )
    for onTickListenerID in onTickListenerIDs {
      try await clock.removeOnTickListener(
        withID: onTickListenerID,
        ofType: CountingOnTickListener.self
      )
    }
  }
}
