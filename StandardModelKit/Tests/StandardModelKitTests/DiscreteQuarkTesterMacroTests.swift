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
        as: "#expect($quark is Particle)"
      )
      struct QuarkTests {}
      """,
      expandedSource: """
        import StandardModel
        import Testing
        struct QuarkTests {

            @Test func greenUpQuarkIsAParticle() {
                #expect(UpQuark(green) is Particle)
            }

            @Test func blueUpQuarkIsAParticle() {
                #expect(UpQuark(blue) is Particle)
            }

            @Test func greenDownQuarkIsAParticle() {
                #expect(DownQuark(green) is Particle)
            }

            @Test func blueDownQuarkIsAParticle() {
                #expect(DownQuark(blue) is Particle)
            }
        }
        """,
      macros: macros
    )
  }
}
