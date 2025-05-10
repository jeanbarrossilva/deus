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

  @Test func nonThousandDivisibleAmountOfMicrosecondsDoesNotContainWholeMillisecond() throws {
    #expect(!Duration.microseconds(2_048).containsWholeMillisecond)
  }

  @Test func thousandDivisibleAmountOfMicrosecondsContainsWholeMillisecond() throws {
    #expect(Duration.microseconds(2_000).containsWholeMillisecond)
  }

  @Test func millisecondFactorEqualsToAmountOfMicrosecondsInOneMillisecond() throws {
    #expect(Duration.millisecondFactor == Duration.milliseconds(1).inMicroseconds)
  }

  @Test(arguments: 0...128)
  func wholeMillisecondIsContained(by value: Int) throws {
    #expect(Duration.milliseconds(value).containsWholeMillisecond)
  }
}
