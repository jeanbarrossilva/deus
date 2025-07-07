// ===-------------------------------------------------------------------------------------------===
// Copyright © 2025 Deus
//
// This file is part of the Deus open-source project.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
// even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If
// not, see https://www.gnu.org/licenses.
// ===-------------------------------------------------------------------------------------------===

import Testing

@testable import Geometry

struct TwoDTests {
  @Test
  func returnsZero2DAbstractionWhenRequestingOneAtZeroZero() throws {
    #expect(Vector.at(x: 0, y: 0) === Vector.zero)
  }

  @Test
  func returnsRhsWhenSummingZero2DAbstractionToIt() throws {
    let rhs = Vector.at(x: 3, y: 4)
    #expect(rhs + Vector.at(x: 0, y: 0) === rhs)
  }

  @Test
  func returnsLhsWhenSummingItToZero2DAbstraction() throws {
    let lhs = Vector.at(x: 3, y: 4)
    #expect(Vector.at(x: 0, y: 0) + lhs === lhs)
  }

  @Test
  func sumsNonZero2DAbstractions() throws {
    #expect(Point.at(x: 1, y: 2) + .at(x: 3, y: 4) == .at(x: 4, y: 6))
  }

  @Test
  func returnsLhsWhenSubtractingTheZeroVectorFromIt() throws {
    let lhs = Vector.at(x: 3, y: 4)
    #expect(lhs - .at(x: 0, y: 0) === lhs)
  }

  @Test
  func returnsZeroVectorWhenSubtractingTwoEqualVectors() throws {
    #expect(Vector.at(x: 3, y: 4) - .at(x: 3, y: 4) === Vector.at(x: 0, y: 0))
  }

  @Test
  func subtracts() throws { #expect(Point.at(x: 3, y: 4) - .at(x: 1, y: 2) == .at(x: 2, y: 2)) }
}
