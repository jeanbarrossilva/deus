//
//  Complex+RealTypeTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 02/06/25.
//

import Numerics
import Testing

@testable import StandardKit

struct ComplexPlusRealTypeTests {
  @Test func multipliesByScalar() {
    #expect(Complex(2.0, 4) * 2.0 == .init(4, 8))
  }
}
