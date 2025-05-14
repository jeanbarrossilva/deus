//
//  DurationTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 30/04/25.
//

import Testing

@testable import NewtonianKit

struct DurationTests {
  @Test func zeroEqualsToZeroMicroseconds() throws {
    #expect(Duration.zero == .microseconds(0))
  }

  @Test func zeroEqualsToZeroMilliseconds() throws {
    #expect(Duration.zero == .milliseconds(0))
  }

  @Test func millisecondFactorEqualsToAmountOfMicrosecondsInOneMillisecond() throws {
    #expect(Duration.millisecondFactor == Duration.milliseconds(1).inMicroseconds)
  }
}
