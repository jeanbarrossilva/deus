//
//  VirtualSubtickerTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 29/04/25.
//

import Testing

@testable import NewtonianKit

struct VirtualSubtickerTests {
  let subticker = VirtualSubticker()

  init() async {
    await subticker.resume()
  }

  @Test func elapsedTimeIncreasesPerSubtick() async throws {
    await subticker.advance(by: .subticks(2))
    print(await subticker.elapsedTime)
    #expect(await subticker.elapsedTime == .subticks(2))
    await subticker.stop()
  }

  @Test func scheduledActionIsExecutedPerSubtick() async throws {
    var actionExecutionCount = 0
    await subticker.schedule { actionExecutionCount += 1 }
    await subticker.advance(by: .subticks(2))
    #expect(actionExecutionCount == 3)
    await subticker.stop()
  }

  @Test func doesNotAdvanceTimeWhenPaused() async throws {
    await subticker.pause()
    await subticker.advance(by: .subticks(2))
    #expect(await subticker.elapsedTime == .zero)
    await subticker.stop()
  }

  @Test func doesNotExecuteScheduledActionWhenPaused() async throws {
    var actionExecutionCount = 0
    await subticker.schedule { actionExecutionCount += 1 }
    await subticker.pause()
    await subticker.advance(by: .subticks(2))
    #expect(actionExecutionCount == 0)
    await subticker.stop()
  }

  @Test func performsPendingTimeAdvancementsWhenResumed() async throws {
    await subticker.pause()
    await subticker.advance(by: .subticks(2))
    await subticker.resume()
    #expect(await subticker.elapsedTime == .subticks(2))
    await subticker.stop()
  }

  @Test func doesNotExecuteScheduledActionWhenStopped() async throws {
    var actionExecutionCount = 0
    await subticker.schedule { actionExecutionCount += 1 }
    await subticker.stop()
    await subticker.advance(by: .subticks(2))
    #expect(actionExecutionCount == 0)
  }
}
