//
//  ClockTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 28/04/25.
//

import Testing

@testable import NewtonianKit

struct ClockTests {
  private lazy var subticker = VirtualSubticker()
  private lazy var clock = Clock(subticker: subticker)

  init() async {
    await clock.start()
  }

  @Test(arguments: [
    [CountingOnTickListener()],
    [CountingOnTickListener](count: 2) { _ in CountingOnTickListener() },
  ])
  mutating func adds(onTickListeners: [CountingOnTickListener]) async throws {
    for listener in onTickListeners { let _ = await clock.add(onTickListener: listener) }
    await subticker.advance(by: .ticks(2))
    for listener in onTickListeners { #expect(listener.count == 3) }
    await clock.stop()
  }

  @Test(arguments: [
    [CountingOnTickListener()],
    [CountingOnTickListener](count: 2) { _ in CountingOnTickListener() },
  ])
  mutating func removes(onTickListeners: [CountingOnTickListener]) async throws {
    let ids = await onTickListeners.map { listener in await clock.add(onTickListener: listener) }
    for id in ids { await clock.removeOnTickListener(identifiedAs: id) }
    await subticker.advance(by: .ticks(2))
    for listener in onTickListeners { #expect(listener.count == 0) }
    await clock.stop()
  }

  @Test mutating func pausesSubtickerUponPause() async throws {
    await clock.pause()
    await subticker.advance(by: .ticks(2))
    #expect(await subticker.elapsedTime == .zero)
    await subticker.resume()
    #expect(await subticker.elapsedTime == .ticks(2))
  }

  @Test mutating func stopsSubtickerUponStop() async throws {
    await clock.stop()
    await subticker.advance(by: .ticks(2))
    #expect(await subticker.elapsedTime == .zero)
  }

  @Test mutating func removesOnTickListenersUponStop() async throws {
    let listeners = [CountingOnTickListener](count: 2) { _ in CountingOnTickListener() }
    for listener in listeners { let _ = await clock.add(onTickListener: listener) }
    await clock.stop()
    await subticker.advance(by: .ticks(2))
    for listener in listeners { #expect(listener.count == 0) }
  }
}
