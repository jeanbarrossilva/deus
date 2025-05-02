//
//  ClockTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 28/04/25.
//

import Testing

@testable import NewtonianKit

struct ClockTests {
  private let subticker = VirtualSubticker()
  private var clock: Clock { Clock(subticker: subticker) }

  init() async {
    await clock.start()
  }

  @Test func ticksAreListenedTo() async throws {
    var onTickListenerIDs = await clock.addOnTickListener(
      initializer: { CountingOnTickListener() },
      count: 2
    )
    await subticker.advance(by: .ticks(2))
    for onTickListenerID in onTickListenerIDs {
      let onTickListener = try await clock.removeOnTickListener(
        withID: onTickListenerID,
        ofType: CountingOnTickListener.self
      )
      #expect(onTickListener.count == 3)
    }
  }

  @Test
  func onTickListenersAreRemoved() async throws {
    let onTickListenerIDs = await clock.addOnTickListener(
      initializer: { CountingOnTickListener() },
      count: 2
    )
    for onTickListenerID in onTickListenerIDs {
      try await clock.removeOnTickListener(
        withID: onTickListenerID,
        ofType: CountingOnTickListener.self
      )
      #expect(
        throws: UnknownTickListenerError.self,
        performing: {
          clock.removeOnTickListener(withID: onTickListenerID, ofType: CountingOnTickListener.self)
        }
      )
    }
    await clock.stop()
  }

  @Test func removesOnTickListenersOnStop() async throws {
    let onTickListenerID = await clock.add(onTickListener: CountingOnTickListener())
    await clock.stop()
    #expect(
      throws: UnknownTickListenerError.self,
      performing: {
        clock.removeOnTickListener(withID: onTickListenerID, ofType: CountingOnTickListener.self)
      }
    )
  }
}
