//
//  CountingTimeLapseListenerTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 29/04/25.
//

import Testing

@testable import RelativityKit

struct CountingTimeLapseListenerTests {
  @Test func countIsZeroByDefault() throws {
    #expect(CountingTimeLapseListener().count == 0)
  }

  @Test func counts() async throws {
    let listener = CountingTimeLapseListener()
    let lapse =
      stride(from: Duration.zero, to: .milliseconds(64), by: Duration.millisecondFactor).map {
        meantime in meantime
      }
    for meantime in lapse {
      await listener.timeDidElapse(
        from: lapse.first!,
        after: meantime == .zero ? nil : meantime - .milliseconds(1),
        to: meantime,
        toward: lapse.last!
      )
    }
    #expect(listener.count == 64)
  }
}
