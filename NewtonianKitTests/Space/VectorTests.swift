//
//  VectorTests.swift
//  NewtonianKitTests
//
//  Created by Jean Barros Silva on 28/04/25.
//

import Testing

@testable import NewtonianKit

struct VectorTests {
  @Test func moduleOfZeroVectorIsZero() throws {
    #expect(Vector.at(x: 0, y: 0).module == 0)
  }

  @Test func calculatesModuleOfNonZeroVector() throws {
    #expect(Vector.at(x: 3, y: 4).module == 5)
  }

  @Test func zeroVectorHasNoUnitaryVector() throws {
    #expect(Vector.at(x: 0, y: 0).unitary == nil)
  }

  @Test func unitaryVectorOfUnitaryVectorIsItself() throws {
    let unitaryVector = Vector.at(x: 1, y: 0)
    #expect(unitaryVector.unitary === unitaryVector)
  }

  @Test func calculatesUnitaryVectorOfNonZeroVector() throws {
    #expect(Vector.at(x: 3, y: 4).unitary == Vector.at(x: 0.6, y: 0.8))
  }
}
