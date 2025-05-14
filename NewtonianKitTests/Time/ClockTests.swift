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
    await clock.reset()
  }

  @Test func ignoresTimeAdvancementsWhenStartedAfterPaused() async throws {
    await clock.pause()
    await clock.advanceTime(by: .microseconds(2))
    await clock.start()
    #expect(await clock.elapsedTime == .zero)
    await clock.reset()
  }

  @Test func ignoresTimeAdvancementsWhenStartedAfterReset() async throws {
    await clock.reset()
    await clock.advanceTime(by: .microseconds(2))
    await clock.start()
    #expect(await clock.elapsedTime == .zero)
    await clock.reset()
  }

  @Test(arguments: [
    [CountingTimeLapseListener()],
    [CountingTimeLapseListener](count: 2) { _ in CountingTimeLapseListener() },
  ])
  mutating func adds(timeLapseListeners: [CountingTimeLapseListener]) async throws {
    for listener in timeLapseListeners { let _ = await clock.addTimeLapseListener(listener) }
    await clock.advanceTime(by: .milliseconds(2))
    for listener in timeLapseListeners { #expect(listener.count == 3) }
    await clock.reset()
  }

  @Test
  func startTimePassedIntoTimeLapseListenerEqualsToThatElapsedUponAdvancementRequest() async throws
  {
    await clock.advanceTime(by: .milliseconds(2))
    let _ =
      await clock.addTimeLapseListener { start, _, _, _ in #expect(start == .milliseconds(2)) }
    await clock.advanceTime(by: .milliseconds(2))
    await clock.reset()
  }

  @Test
  func previousTimeIsNilWhenTimeLapseIsNotifiedToListenerAfterClockIsJustStarted() async throws {
    let listener = CountingTimeLapseListener()
    let _ = await clock.addTimeLapseListener { _, previous, _, _ in
      guard listener.count == 0 else { return }
      #expect(previous == nil)
    }
    let _ = await clock.addTimeLapseListener(listener)
    await clock.advanceTime(by: .milliseconds(1))
    await clock.reset()
  }

  @Test func previousTimePassedIntoTimeLapseListenerEqualsToLastElapsedOneAtPause() async throws {
    let listener = CountingTimeLapseListener()
    let _ = await clock.addTimeLapseListener { _, previous, _, _ in
      switch listener.count {
      case 4:
        #expect(previous == .milliseconds(3))
      case 5:
        #expect(previous == .milliseconds(4))
      default:
        return
      }
    }
    let _ = await clock.addTimeLapseListener(listener)
    await clock.advanceTime(by: .milliseconds(2))
    await clock.reset()
    await clock.advanceTime(by: .milliseconds(1))
    await clock.reset()
  }

  @Test
  func previousTimePassedIntoTimeLapseListenerIsOneMicrosecondLessThanCurrentOne() async throws {
    let listener = CountingTimeLapseListener()
    let _ = await clock.addTimeLapseListener { _, previous, current, _ in
      guard listener.count > 0 else { return }
      #expect(previous == current - .milliseconds(1))
    }
    let _ = await clock.addTimeLapseListener(listener)
    await clock.advanceTime(by: .milliseconds(2))
    await clock.reset()
  }

  @Test func currentTimePassedIntoTimeLapseListenerEqualsToElapsedOneOfClock() async throws {
    let _ = await clock.addTimeLapseListener { _, _, current, _ in
      #expect(await current == clock.elapsedTime)
    }
    await clock.advanceTime(by: .milliseconds(2))
    await clock.reset()
  }

  @Test
  func endTimePassedIntoTimeLapseListenerIsEqualToThatToWhichTheTimeIsAdvancedToward() async throws
  {
    let _ = await clock.addTimeLapseListener { _, _, _, end in #expect(end == .milliseconds(2)) }
    await clock.advanceTime(by: .milliseconds(2))
    await clock.reset()
  }

  @Test(arguments: [
    [CountingTimeLapseListener()],
    [CountingTimeLapseListener](count: 2) { _ in CountingTimeLapseListener() },
  ])
  mutating func removes(timeLapseListeners: [CountingTimeLapseListener]) async throws {
    let ids =
      await timeLapseListeners.map { listener in await clock.addTimeLapseListener(listener) }
    for id in ids { await clock.removeTimeLapseListener(identifiedAs: id) }
    await clock.advanceTime(by: .milliseconds(2))
    for listener in timeLapseListeners { #expect(listener.count == 0) }
    await clock.reset()
  }

  @Test mutating func pauses() async throws {
    await clock.advanceTime(by: .milliseconds(2))
    await clock.pause()
    await clock.start()
    await clock.advanceTime(by: .milliseconds(2))
    #expect(await clock.elapsedTime == .milliseconds(4))
  }

  @Test mutating func resets() async throws {
    await clock.advanceTime(by: .milliseconds(2))
    await clock.reset()
    await clock.advanceTime(by: .milliseconds(2))
    await clock.start()
    #expect(await clock.elapsedTime == .zero)
  }

  @Test(arguments: [
    [CountingTimeLapseListener()],
    [CountingTimeLapseListener](count: 2) { _ in CountingTimeLapseListener() },
  ])
  mutating func removesUponReset(timeLapseListeners: [CountingTimeLapseListener]) async throws {
    for listener in timeLapseListeners { let _ = await clock.addTimeLapseListener(listener) }
    await clock.reset()
    await clock.advanceTime(by: .milliseconds(2))
    for listener in timeLapseListeners { #expect(listener.count == 0) }
  }
}
