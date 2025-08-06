// ===-------------------------------------------------------------------------------------------===
// Copyright © 2025 Deus
//
// This file is part of the Deus open-source project.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
// even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If
// not, see https://www.gnu.org/licenses.
// ===-------------------------------------------------------------------------------------------===

import StandardModelKitMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class DiscreteQuarkTesterMacroTests: XCTestCase {
  private let macros = ["DiscreteQuarkTester": DiscreteQuarkTesterMacro.self]

  func testExpansion() throws {
    assertMacroExpansion(
      """
      import StandardModel
      import Testing

      @DiscreteQuarkTester(
        derivingNameFrom: "quarkIsAParticle",
        ofTypes: [.up([.charm, .top]), .down([.strange, .bottom])],
        colored: [.green, .blue],
        as: "#expect(quark is Particle)"
      )
      struct QuarkTests {}
      """,
      expandedSource: """
        import StandardModel
        import Testing
        struct QuarkTests {

            @Test
            func greenCharmQuarkIsAParticle() {
              let color = green
              let quark = CharmQuark(color: color)
              #expect(quark is Particle)
            }

            @Test
            func blueCharmQuarkIsAParticle() {
              let color = blue
              let quark = CharmQuark(color: color)
              #expect(quark is Particle)
            }

            @Test
            func greenTopQuarkIsAParticle() {
              let color = green
              let quark = TopQuark(color: color)
              #expect(quark is Particle)
            }

            @Test
            func blueTopQuarkIsAParticle() {
              let color = blue
              let quark = TopQuark(color: color)
              #expect(quark is Particle)
            }

            @Test
            func greenStrangeQuarkIsAParticle() {
              let color = green
              let quark = StrangeQuark(color: color)
              #expect(quark is Particle)
            }

            @Test
            func blueStrangeQuarkIsAParticle() {
              let color = blue
              let quark = StrangeQuark(color: color)
              #expect(quark is Particle)
            }

            @Test
            func greenBottomQuarkIsAParticle() {
              let color = green
              let quark = BottomQuark(color: color)
              #expect(quark is Particle)
            }

            @Test
            func blueBottomQuarkIsAParticle() {
              let color = blue
              let quark = BottomQuark(color: color)
              #expect(quark is Particle)
            }
        }
        """,
      macros: macros
    )
  }
}
