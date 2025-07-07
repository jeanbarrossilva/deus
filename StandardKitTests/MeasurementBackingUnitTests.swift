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

import Testing

@testable import StandardKit

struct MeasurementBackingUnitTests {
  @Test
  func angleBackingUnitIsRadians() {
    #expect(Angle.make(value: 0).symbol == Angle.backingUnitSymbol)
    #expect(Angle.backingUnitSymbol == Angle.radians(0).symbol)
    #expect(Angle.radians(2).value == 2)
  }

  @Test
  func chargeBackingUnitIsElementary() {
    #expect(Charge.make(value: 0).symbol == Charge.backingUnitSymbol)
    #expect(Charge.backingUnitSymbol == Charge.elementary(0).symbol)
    #expect(Charge.elementary(2).value == 2)
  }

  @Test
  func energyBackingUnitIsMegaelectronvolts() {
    #expect(Energy.make(value: 0).symbol == Energy.backingUnitSymbol)
    #expect(Energy.backingUnitSymbol == Energy.megaelectronvolts(0).symbol)
    #expect(Energy.megaelectronvolts(2).value == 2)
  }
}
