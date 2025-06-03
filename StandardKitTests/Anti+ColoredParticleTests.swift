//
//  Anti+ColoredParticleTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 02/06/25.
//

import Testing

@testable import StandardKit

struct ColoredAntiparticleTests {
  @Test(arguments: Color.allCases) func isColoredWithAnticolor(of color: Color) {
    #expect(Anti(Quark.up(color: color)).color == .anti(color))
  }
}
