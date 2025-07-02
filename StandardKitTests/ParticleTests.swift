//
//  ParticleTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.07.02.
//

import Testing

@testable import StandardKit

@Suite("Particle tests")
struct ParticleTests {
  @Test
  func arePartiallyEqual() {
    #expect(UpQuark(color: .red).isPartiallyEqual(to: UpQuark(color: .green)))
  }

  @Test
  func areNotPartiallyEqual() {
    #expect(!UpQuark(color: .red).isPartiallyEqual(to: DownQuark(color: .red)))
  }
}
