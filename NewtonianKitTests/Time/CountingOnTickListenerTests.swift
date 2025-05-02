//
//  CountingOnTickListenerTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 29/04/25.
//

import Testing

@testable import NewtonianKit

struct CountingOnTickListenerTests {
  @Test func countIsZeroByDefault() throws {
    #expect(CountingOnTickListener().count == 0)
  }

  @Test func counts() async throws {
    var onTickListener = CountingOnTickListener()
    for _ in 0..<64 { await onTickListener.onTick() }
    #expect(onTickListener.count == 64)
  }
}
