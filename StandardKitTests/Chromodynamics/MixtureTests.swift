//
//  MixtureTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.20.
//

import Testing

@testable import StandardKit

struct MixtureTests {
  @Suite("Combination") struct CombinationTests {
    @Test(arguments: Color.allCases) func whitePlusColorIsColor(_ color: Color) {
      #expect(Mixture.white + color == .of(color))
    }

    @Test(
      arguments: zip(
        [Mixture.brown, .purple, .cyan].spread(count: { _ in 2 }),
        [Mixture.brown, .purple, .cyan].flatMap(\.colors)
      )
    )
    func twoColorMixturePlusOneOfItsColorsIsTheMixtureItself(_ mixture: Mixture, _ color: Color) {
      #expect(mixture + color == mixture)
    }
  }

  @Test func obtainsMixtureOfRed() {
    #expect(Mixture.of(.red) == .red)
  }

  @Test func obtainsMixtureOfGreen() {
    #expect(Mixture.of(.green) == .green)
  }

  @Test func obtainsMixtureOfBlue() {
    #expect(Mixture.of(.blue) == .blue)
  }
}

extension Array {
  /// Makes an `Array` in which each element of this one is repeated consecutively by the specified
  /// amount of times.
  ///
  /// - Parameter count: Determines the amount of times the given element will be repeated in the
  ///   returned `Array`.
  func spread(count: (Element) throws -> Int) rethrows -> Self {
    guard !isEmpty else { return self }
    let counts = try map(count)
    let totalCount = counts.reduce(0, +)
    guard totalCount != self.count else { return self }
    guard totalCount > 0 else { return [] }
    return [Element](
      unsafeUninitializedCapacity: totalCount,
      initializingWith: { buffer, initializedCount in
        var offset = 0
        for (index, element) in enumerated() {
          for _ in 1...counts[index] {
            buffer.baseAddress?.advanced(by: offset).initialize(to: element)
            offset += 1
          }
        }
        initializedCount = totalCount
      }
    )
  }
}
