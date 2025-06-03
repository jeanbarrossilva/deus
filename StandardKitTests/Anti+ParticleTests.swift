//
//  Anti+ParticleTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 02/06/25.
//

import Testing

@testable import StandardKit

struct AntiparticleTests {
  @Test func chargeIsOpposite() {
    #expect(Anti(Quark.up(color: .red)).charge == -Charge.elementary(2 / 3))
  }

  @Test func symbolHasOverbar() {
    #expect(Anti(Quark.up(color: .red)).symbol == "u̅")
  }
}
