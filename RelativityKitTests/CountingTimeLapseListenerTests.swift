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

@testable import RelativityKit

struct CountingTimeLapseListenerTests {
  @Test func countIsZeroByDefault() throws {
    #expect(CountingTimeLapseListener().count == 0)
  }

  @Test func counts() async throws {
    let listener = CountingTimeLapseListener()
    let lapse =
      stride(from: Duration.zero, to: .milliseconds(64), by: Duration.millisecondFactor).map {
        meantime in meantime
      }
    for meantime in lapse {
      await listener.timeDidElapse(
        from: lapse.first!,
        after: meantime == .zero ? nil : meantime - .milliseconds(1),
        to: meantime,
        toward: lapse.last!
      )
    }
    #expect(listener.count == 64)
  }
}
