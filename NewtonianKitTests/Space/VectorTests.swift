//
//  NewtonianKitTests.swift
//  NewtonianKitTests
//
//  Created by Jean Barros Silva on 28/04/25.
//

import Testing

@testable import NewtonianKit

struct VectorTests {
  @Test func returnsSameVectorWhenCreatingZeroVectorTwice() throws {
    #expect(Vector.at(x: 0, y: 0) === Vector.at(x: 0, y: 0))
  }

  @Test func moduleOfZeroVectorIsZero() throws {
    #expect(Vector.at(x: 0, y: 0).module == 0)
  }

  @Test func calculatesModuleOfNonZeroVector() throws {
    #expect(Vector.at(x: 3, y: 4).module == 5)
  }

  @Test func zeroVectorHasNoUnitaryVector() throws {
    #expect(Vector.at(x: 0, y: 0).unitary == nil)
  }

  @Test func calculatesUnitaryVectorOfNonZeroVector() throws {
    #expect(Vector.at(x: 3, y: 4).unitary == Vector.at(x: 0.6, y: 0.8))
  }

  @Test func returnsRhsWhenSummingTheZeroVectorToIt() throws {
    let rhs = Vector.at(x: 3, y: 4)
    #expect(rhs + Vector.at(x: 0, y: 0) === rhs)
  }

  @Test func returnsLhsWhenSummingItToTheZeroVector() throws {
    let lhs = Vector.at(x: 3, y: 4)
    #expect(Vector.at(x: 0, y: 0) + lhs === lhs)
  }

  @Test func sumsNonZeroVectors() throws {
    #expect(Vector.at(x: 1, y: 2) + Vector.at(x: 3, y: 4) == Vector.at(x: 4, y: 6))
  }

  @Test func returnsLhsWhenSubtractingTheZeroVectorFromIt() throws {
    let lhs = Vector.at(x: 3, y: 4)
    #expect(lhs - Vector.at(x: 0, y: 0) === lhs)
  }

  @Test func returnsZeroVectorWhenSubtractingTwoEqualVectors() throws {
    #expect(Vector.at(x: 3, y: 4) - Vector.at(x: 3, y: 4) === Vector.at(x: 0, y: 0))
  }

  @Test func subtracts() throws {
    #expect(Vector.at(x: 3, y: 4) - Vector.at(x: 1, y: 2) == Vector.at(x: 2, y: 2))
  }

  @Test func coordinatesOfZeroVectorAreZero() throws {
    #expect(Vector.at(x: 0, y: 0) === Vector.at(x: 0, y: 0))
  }
}
