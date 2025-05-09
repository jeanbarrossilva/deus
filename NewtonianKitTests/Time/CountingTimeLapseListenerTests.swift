//
//  CountingTimeLapseListenerTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 29/04/25.
//

import Testing

@testable import NewtonianKit

struct CountingTimeLapseListenerTests {
  @Test func countIsZeroByDefault() throws {
    #expect(CountingTimeLapseListener().count == 0)
  }

  @Test func counts() async throws {
    let timeLapseListener = CountingTimeLapseListener()
    for _ in 0..<64 { await timeLapseListener.timeDidElapse() }
    #expect(timeLapseListener.count == 64)
  }
}
