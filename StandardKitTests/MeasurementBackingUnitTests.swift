import Testing

@testable import StandardKit

struct MeasurementBackingUnitTests {
  @Test func chargeBackingUnitIsElementary() {
    #expect(Charge.make(value: 0).symbol == Charge.backingUnitSymbol)
    #expect(Charge.backingUnitSymbol == Charge.elementary(0).symbol)
    #expect(Charge.elementary(2).value == 2)
  }

  @Test func energyBackingUnitIsMegaelectronvolt() {
    #expect(Energy.make(value: 0).symbol == Energy.backingUnitSymbol)
    #expect(Energy.backingUnitSymbol == Energy.megaelectronvolt(0).symbol)
    #expect(Energy.megaelectronvolt(2).value == 2)
  }
}
