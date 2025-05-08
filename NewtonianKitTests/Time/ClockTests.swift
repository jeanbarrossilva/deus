//
//  ClockTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 28/04/25.
//

import Testing

@testable import NewtonianKit

struct ClockTests {
  private var clock = Clock()

  init() async {
    await clock.start()
  }

  @Test func elapsedTimeIncreasesPerSubtick() async throws {
    await clock.advanceTime(by: .microseconds(2))
    #expect(await clock.elapsedTime == .microseconds(2))
    await clock.stop()
  }

  @Test func ignoresTimeAdvancementsWhenStartedAfterPaused() async throws {
    await clock.pause()
    await clock.advanceTime(by: .microseconds(2))
    await clock.start()
    #expect(await clock.elapsedTime == .zero)
    await clock.stop()
  }

  @Test func ignoresTimeAdvancementsWhenStartedAfterStopped() async throws {
    await clock.stop()
    await clock.advanceTime(by: .microseconds(2))
    await clock.start()
    #expect(await clock.elapsedTime == .zero)
    await clock.stop()
  }

  @Test(arguments: [
    [CountingOnTickListener()],
    [CountingOnTickListener](count: 2) { _ in CountingOnTickListener() },
  ])
  mutating func adds(onTickListeners: [CountingOnTickListener]) async throws {
    for listener in onTickListeners { let _ = await clock.add(onTickListener: listener) }
    await clock.advanceTime(by: .milliseconds(2))
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
    await clock.advanceTime(by: .milliseconds(2))
    for listener in onTickListeners { #expect(listener.count == 0) }
    await clock.stop()
  }

  @Test mutating func pauses() async throws {
    await clock.advanceTime(by: .milliseconds(2))
    await clock.pause()
    await clock.start()
    await clock.advanceTime(by: .milliseconds(2))
    #expect(await clock.elapsedTime == .milliseconds(4))
  }

  @Test mutating func stops() async throws {
    await clock.advanceTime(by: .milliseconds(2))
    await clock.stop()
    await clock.advanceTime(by: .milliseconds(2))
    await clock.start()
    #expect(await clock.elapsedTime == .zero)
  }

  @Test(arguments: [
    [CountingOnTickListener()],
    [CountingOnTickListener](count: 2) { _ in CountingOnTickListener() },
  ])
  mutating func removesUponStop(onTickListeners: [CountingOnTickListener]) async throws {
    for listener in onTickListeners { let _ = await clock.add(onTickListener: listener) }
    await clock.stop()
    await clock.advanceTime(by: .milliseconds(2))
    for listener in onTickListeners { #expect(listener.count == 0) }
  }
}
