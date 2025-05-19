//
//  2DTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 17/05/25.
//

import Testing

@testable import NewtonianKit

struct TwoDTests {
  @Test func returnsZero2DAbstractionWhenRequestingOneAtZeroZero() throws {
    #expect(Vector.at(x: 0, y: 0) === Vector.zero)
  }

  @Test func returnsRhsWhenSummingZero2DAbstractionToIt() throws {
    let rhs = Vector.at(x: 3, y: 4)
    #expect(rhs + Vector.at(x: 0, y: 0) === rhs)
  }

  @Test func returnsLhsWhenSummingItToZero2DAbstraction() throws {
    let lhs = Vector.at(x: 3, y: 4)
    #expect(Vector.at(x: 0, y: 0) + lhs === lhs)
  }

  @Test func sumsNonZero2DAbstractions() throws {
    #expect(Point.at(x: 1, y: 2) + .at(x: 3, y: 4) == .at(x: 4, y: 6))
  }

  @Test func returnsLhsWhenSubtractingTheZeroVectorFromIt() throws {
    let lhs = Vector.at(x: 3, y: 4)
    #expect(lhs - .at(x: 0, y: 0) === lhs)
  }

  @Test func returnsZeroVectorWhenSubtractingTwoEqualVectors() throws {
    #expect(Vector.at(x: 3, y: 4) - .at(x: 3, y: 4) === Vector.at(x: 0, y: 0))
  }

  @Test func subtracts() throws {
    #expect(Point.at(x: 3, y: 4) - .at(x: 1, y: 2) == .at(x: 2, y: 2))
  }
}
