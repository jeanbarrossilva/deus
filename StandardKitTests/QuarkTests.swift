//
//  ChargeTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 25/05/25.
//

import Testing

@testable import StandardKit

struct QuarkTests {
  @Test func upQuarkSymbolIsU() {
    #expect(UpQuark.symbol == "u")
  }

  @Test func downQuarkSymbolIsD() {
    #expect(DownQuark.symbol == "d")
  }

  @Test func strangeQuarkSymbolIsS() {
    #expect(StrangeQuark.symbol == "s")
  }

  @Test func charmQuarkSymbolIsC() {
    #expect(CharmQuark.symbol == "c")
  }

  @Test func bottomQuarkSymbolIsB() {
    #expect(BottomQuark.symbol == "b")
  }

  @Test func topQuarkSymbolIsT() {
    #expect(TopQuark.symbol == "t")
  }

  @Test func chargeOfUpTypeQuarksIsTwoThirdsOfE() {
    #expect(UpQuark.charge == CharmQuark.charge)
    #expect(CharmQuark.charge == TopQuark.charge)
    #expect(TopQuark.charge == .elementary(2 / 3))
  }

  @Test func chargeOfDownTypeQuarksIsNegativeOneThirdOfE() {
    #expect(DownQuark.charge == StrangeQuark.charge)
    #expect(StrangeQuark.charge == BottomQuark.charge)
    #expect(BottomQuark.charge == .elementary(-1 / 3))
  }

  @Test func quarksAreComparedByMass() {
    let down = DownQuark()
    let strange = StrangeQuark()
    let charm = CharmQuark()
    let bottom = BottomQuark()
    #expect(UpQuark() < down)
    #expect(down < strange)
    #expect(strange < charm)
    #expect(charm < bottom)
    #expect(bottom < TopQuark())
  }
}
