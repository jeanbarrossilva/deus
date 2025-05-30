//
//  ChargeTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 25/05/25.
//

import Testing

@testable import StandardKit

struct QuarkTests {
  @Test func spinIsHalf() {
    #expect(Quark.spin == .half)
  }

  @Test func upQuarkSymbolIsU() {
    #expect(Quark.up.symbol == "u")
  }

  @Test func downQuarkSymbolIsD() {
    #expect(Quark.down.symbol == "d")
  }

  @Test func charmQuarkSymbolIsC() {
    #expect(Quark.charm.symbol == "c")
  }

  @Test func strangeQuarkSymbolIsS() {
    #expect(Quark.strange.symbol == "s")
  }

  @Test func topQuarkSymbolIsT() {
    #expect(Quark.top.symbol == "t")
  }

  @Test func bottomQuarkSymbolIsB() {
    #expect(Quark.bottom.symbol == "b")
  }

  @Test func chargeOfUpTypeQuarksIsTwoThirdsOfE() {
    #expect(Quark.up.charge == Quark.charm.charge)
    #expect(Quark.charm.charge == Quark.top.charge)
    #expect(Quark.top.charge == .elementary(2 / 3))
  }

  @Test func chargeOfDownTypeQuarksIsNegativeOneThirdOfE() {
    #expect(Quark.down.charge == Quark.strange.charge)
    #expect(Quark.strange.charge == Quark.bottom.charge)
    #expect(Quark.bottom.charge == .elementary(-1 / 3))
  }

  @Test func quarksAreComparedByMass() {
    #expect(Quark.up < .down)
    #expect(Quark.down < .strange)
    #expect(Quark.strange < .charm)
    #expect(Quark.charm < .top)
    #expect(Quark.top < .bottom)
  }
}
