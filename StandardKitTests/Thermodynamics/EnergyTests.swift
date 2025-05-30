//
//  EnergyTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 26/05/25.
//

import Testing

@testable import StandardKit

struct EnergyTests {
  @Test func megaelectronvoltSymbolIsMeV() {
    #expect(Energy.megaelectronvolt(0).symbol == "MeV")
  }

  @Test func gigaelectronvoltSymbolIsGeV() {
    #expect(Energy.gigaelectronvolt(0).symbol == "GeV")
  }
}
