//
//  AngleTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 02/06/25.
//

import Testing

@testable import StandardKit

struct AngleTests {
  @Test func radiansSymbolIsRad() {
    #expect(Angle.radians(0).symbol == "rad")
  }
}
