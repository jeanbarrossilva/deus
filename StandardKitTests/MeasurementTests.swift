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

struct MeasurementTests {
  private struct MeaninglessMeasurement: Measurement {
    static var zero = Self.make(value: 0)
    static var backingUnitSymbol = "❤️‍🩹"

    var value: Double
    let symbol = "💘"

    private init(value: Double) { self.value = value }

    static func make(value: Double) -> Self { .init(value: value) }
  }

  @Test
  func differsFromAnother() { #expect(MeaninglessMeasurement.make(value: 2) != .make(value: 4)) }

  @Test
  func equalsToAnother() { #expect(MeaninglessMeasurement.make(value: 2) == .make(value: 2)) }

  @Test
  func isLessThanAnother() { #expect(MeaninglessMeasurement.make(value: 2) < .make(value: 4)) }

  @Test
  func isGreaterThanAnother() { #expect(MeaninglessMeasurement.make(value: 4) > .make(value: 2)) }

  @Test
  func adds() { #expect((MeaninglessMeasurement.make(value: 2) + .make(value: 2)).value == 4) }

  @Test
  func subtracts() { #expect((MeaninglessMeasurement.make(value: 4) - .make(value: 2)).value == 2) }

  @Test
  func isDescribedByValueAndSymbol() {
    #expect("\(MeaninglessMeasurement.make(value: 2))" == "2 💘")
  }
}
