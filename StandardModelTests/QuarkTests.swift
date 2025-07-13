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

import Foundation
import Testing

@testable import StandardModel

struct QuarkTests {
  @Suite("Symbol")
  struct SymbolTests {
    @Test
    func upQuarkSymbolIsU() { #expect(UpQuark<Red>.symbol == "u") }

    @Test
    func downQuarkSymbolIsD() { #expect(DownQuark<Red>.symbol == "d") }

    @Test
    func charmQuarkSymbolIsC() { #expect(CharmQuark<Red>.symbol == "c") }

    @Test
    func strangeQuarkSymbolIsS() { #expect(StrangeQuark<Red>.symbol == "s") }

    @Test
    func topQuarkSymbolIsT() { #expect(TopQuark<Red>.symbol == "t") }

    @Test
    func bottomQuarkSymbolIsB() { #expect(BottomQuark<Red>.symbol == "b") }
  }

  @Suite("Charge")
  struct ChargeTests {
    @Test
    func chargeOfUpTypeQuarksIsTwoThirdsOfE() {
      #expect(UpQuark(color: red).charge == CharmQuark(color: red).charge)
      #expect(CharmQuark(color: red).charge == TopQuark(color: red).charge)
      #expect(TopQuark(color: red).charge == Measurement(value: 2 / 3, unit: .elementary))
    }

    @Test
    func chargeOfDownTypeQuarksIsNegativeOneThirdOfE() {
      #expect(DownQuark(color: red).charge == StrangeQuark(color: red).charge)
      #expect(StrangeQuark(color: red).charge == BottomQuark(color: red).charge)
      #expect(BottomQuark(color: red).charge == Measurement(value: -1 / 3, unit: .elementary))
    }
  }
}
