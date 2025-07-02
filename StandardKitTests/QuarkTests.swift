//
//  QuarkTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 25/05/25.
//

import Testing

@testable import StandardKit

struct QuarkTests {
  @Suite("Symbol") struct SymbolTests {
    @Test func upQuarkSymbolIsU() {
      #expect(UpQuark.symbol == "u")
    }

    @Test func downQuarkSymbolIsD() {
      #expect(DownQuark.symbol == "d")
    }

    @Test func charmQuarkSymbolIsC() {
      #expect(CharmQuark.symbol == "c")
    }

    @Test func strangeQuarkSymbolIsS() {
      #expect(StrangeQuark.symbol == "s")
    }

    @Test func topQuarkSymbolIsT() {
      #expect(TopQuark.symbol == "t")
    }

    @Test func bottomQuarkSymbolIsB() {
      #expect(BottomQuark.symbol == "b")
    }
  }

  @Suite("Charge") struct ChargeTests {
    @Test func chargeOfUpTypeQuarksIsTwoThirdsOfE() {
      #expect(UpQuark(color: .red).charge == CharmQuark(color: .red).charge)
      #expect(CharmQuark(color: .red).charge == TopQuark(color: .red).charge)
      #expect(TopQuark(color: .red).charge == .elementary(2 / 3))
    }

    @Test func chargeOfDownTypeQuarksIsNegativeOneThirdOfE() {
      #expect(DownQuark(color: .red).charge == StrangeQuark(color: .red).charge)
      #expect(StrangeQuark(color: .red).charge == BottomQuark(color: .red).charge)
      #expect(BottomQuark(color: .red).charge == .elementary(-1 / 3))
    }
  }

  @Suite("Hadronization") struct HadronizationTests {
    @Test func hadronizes() {
    }
  }
}
