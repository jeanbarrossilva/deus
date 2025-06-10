
import Testing

@testable import StandardKit

struct MeasurementBackingUnitTests {
  @Test func angleBackingUnitIsRadians() {
    #expect(Angle.make(value: 0).symbol == Angle.backingUnitSymbol)
    #expect(Angle.backingUnitSymbol == Angle.radians(0).symbol)
    #expect(Angle.radians(2).value == 2)
  }

  @Test func chargeBackingUnitIsElementary() {
    #expect(Charge.make(value: 0).symbol == Charge.backingUnitSymbol)
    #expect(Charge.backingUnitSymbol == Charge.elementary(0).symbol)
    #expect(Charge.elementary(2).value == 2)
  }

  @Test func energyBackingUnitIsMegaelectronvolts() {
    #expect(Energy.make(value: 0).symbol == Energy.backingUnitSymbol)
    #expect(Energy.backingUnitSymbol == Energy.megaelectronvolts(0).symbol)
    #expect(Energy.megaelectronvolts(2).value == 2)
  }
}
