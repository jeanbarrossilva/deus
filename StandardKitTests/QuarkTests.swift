//
//  QuarkTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 25/05/25.
//

import Testing

@testable import StandardKit

struct QuarkTests {
  @Test func upQuarkSymbolIsU() {
    #expect(Quark.up(color: .red).symbol == "u")
  }

  @Test func downQuarkSymbolIsD() {
    #expect(Quark.down(color: .red).symbol == "d")
  }

  @Test func charmQuarkSymbolIsC() {
    #expect(Quark.charm(color: .red).symbol == "c")
  }

  @Test func strangeQuarkSymbolIsS() {
    #expect(Quark.strange(color: .red).symbol == "s")
  }

  @Test func topQuarkSymbolIsT() {
    #expect(Quark.top(color: .red).symbol == "t")
  }

  @Test func bottomQuarkSymbolIsB() {
    #expect(Quark.bottom(color: .red).symbol == "b")
  }

  @Test func chargeOfUpTypeQuarksIsTwoThirdsOfE() {
    #expect(Quark.up(color: .red).charge == Quark.charm(color: .red).charge)
    #expect(Quark.charm(color: .red).charge == Quark.top(color: .red).charge)
    #expect(Quark.top(color: .red).charge == .elementary(2 / 3))
  }

  @Test func chargeOfDownTypeQuarksIsNegativeOneThirdOfE() {
    #expect(Quark.down(color: .red).charge == Quark.strange(color: .red).charge)
    #expect(Quark.strange(color: .red).charge == Quark.bottom(color: .red).charge)
    #expect(Quark.bottom(color: .red).charge == .elementary(-1 / 3))
  }
}
