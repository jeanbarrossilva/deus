//
//  MeasurementTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 26/05/25.
//

import Testing

@testable import StandardKit

struct MeasurementTests {
  private struct MeaninglessMeasurement: Measurement {
    static var zero = Self.make(value: 0)
    static var backingUnitSymbol = "❤️‍🩹"

    var value: Double
    let symbol = "💘"

    private init(value: Double) {
      self.value = value
    }

    static func make(value: Double) -> Self {
      .init(value: value)
    }
  }

  @Test func differsFromAnother() {
    #expect(MeaninglessMeasurement.make(value: 2) != .make(value: 4))
  }

  @Test func equalsToAnother() {
    #expect(MeaninglessMeasurement.make(value: 2) == .make(value: 2))
  }

  @Test func isLessThanAnother() {
    #expect(MeaninglessMeasurement.make(value: 2) < .make(value: 4))
  }

  @Test func isGreaterThanAnother() {
    #expect(MeaninglessMeasurement.make(value: 4) > .make(value: 2))
  }

  @Test func adds() {
    #expect((MeaninglessMeasurement.make(value: 2) + .make(value: 2)).value == 4)
  }

  @Test func subtracts() {
    #expect((MeaninglessMeasurement.make(value: 4) - .make(value: 2)).value == 2)
  }

  @Test func isDescribedByValueAndSymbol() {
    #expect("\(MeaninglessMeasurement.make(value: 2))" == "2 💘")
  }
}
