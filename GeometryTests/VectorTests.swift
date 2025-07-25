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

struct VectorTests {
  @Test
  func moduleOfZeroVectorIsZero() throws { #expect(Vector.at(x: 0, y: 0).module == 0) }

  @Test
  func calculatesModuleOfNonZeroVector() throws { #expect(Vector.at(x: 3, y: 4).module == 5) }

  @Test
  func zeroVectorHasNoUnitaryVector() throws { #expect(Vector.at(x: 0, y: 0).unitary == nil) }

  @Test
  func unitaryVectorOfUnitaryVectorIsItself() throws {
    let unitaryVector = Vector.at(x: 1, y: 0)
    #expect(unitaryVector.unitary === unitaryVector)
  }

  @Test
  func calculatesUnitaryVectorOfNonZeroVector() throws {
    #expect(Vector.at(x: 3, y: 4).unitary == Vector.at(x: 0.6, y: 0.8))
  }
}
