//
//  ChargeTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 24/05/25.
//

import Testing

@testable import StandardKit

struct ChargeTests {
  @Test func elementaryChargeSymbolIsE() {
    #expect(Charge.elementary(0).symbol == "e")
  }
}
