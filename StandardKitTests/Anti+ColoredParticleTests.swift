//
//  Anti+ColoredParticleTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 02/06/25.
//

import Testing

@testable import StandardKit

struct ColoredAntiparticleTests {
  @Test(arguments: Pigment.allCases) func isColoredWithAnticolor(of color: Pigment) {
    #expect(Anti(UpQuark(color: color)).color == .anti(color))
  }
}
