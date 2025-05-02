//
//  SubtickingTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 30/04/25.
//

import Testing

@testable import NewtonianKit

struct SubtickingTests {
  @Test func zeroEqualsToZeroSubticks() throws {
    #expect(Subticking.zero == .subticks(0))
  }

  @Test func zeroEqualsToZeroTicks() throws {
    #expect(Subticking.zero == .ticks(0))
  }

  @Test func nonThousandDivisibleSubtickCountDoesNotContainWholeTick() throws {
    #expect(!Subticking.subticks(2_048).containsWholeTick)
  }

  @Test func thousandDivisibleSubtickCountContainsWholeTick() throws {
    #expect(Subticking.subticks(2_000).containsWholeTick)
  }

  @Test(arguments: 0...128)
  func wholeTickIsContained(by count: Int) throws {
    #expect(Subticking.ticks(count).containsWholeTick)
  }
}
