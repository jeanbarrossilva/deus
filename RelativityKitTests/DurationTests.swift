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

struct DurationTests {
  @Test func zeroEqualsToZeroMicroseconds() throws {
    #expect(Duration.zero == .microseconds(0))
  }

  @Test func zeroEqualsToZeroMilliseconds() throws {
    #expect(Duration.zero == .milliseconds(0))
  }

  @Test func millisecondFactorEqualsToAmountOfMicrosecondsInOneMillisecond() throws {
    #expect(Duration.millisecondFactor == Duration.milliseconds(1).inMicroseconds)
  }

  @Test func convertsMicrosecondsIntoMicroseconds() throws {
    #expect(Duration.microseconds(2).inMicroseconds == 2)
  }

  @Test func convertsMicrosecondsIntoMilliseconds() throws {
    #expect(Duration.microseconds(2).inMilliseconds == 0.002)
  }

  @Test func convertsMillisecondsIntoMicroseconds() throws {
    #expect(Duration.milliseconds(2).inMicroseconds == 2_000)
  }

  @Test func convertsMillisecondsIntoMilliseconds() throws {
    #expect(Duration.milliseconds(2).inMilliseconds == 2)
  }

  @Test func convertsSecondsIntoMicroseconds() throws {
    #expect(Duration.seconds(2).inMicroseconds == 2_000_000)
  }

  @Test func convertsSecondsIntoMilliseconds() throws {
    #expect(Duration.seconds(2).inMilliseconds == 2_000)
  }
}
