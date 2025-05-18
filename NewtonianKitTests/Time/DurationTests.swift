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

  @Test func convertsMicrosecondsIntoMicroseconds() throws {
    #expect(Duration.microseconds(2).inMicroseconds == 2)
  }
  
  @Test func convertsMicrosecondsIntoMilliseconds() throws {
    #expect(Duration.microseconds(2).inMilliseconds == 0.002)
  }

  @Test func convertsMillisecondsIntoMicroseconds() throws {
    #expect(Duration.milliseconds(2).inMicroseconds == 2_000)
  }

  @Test func convertsMillisecondsIntoMilliseconds() throws {
    #expect(Duration.milliseconds(2).inMilliseconds == 2)
  }

  @Test func convertsSecondsIntoMicroseconds() throws {
    #expect(Duration.seconds(2).inMicroseconds == 2_000_000)
  }

  @Test func convertsSecondsIntoMilliseconds() throws {
    #expect(Duration.seconds(2).inMilliseconds == 2_000)
  }
}
