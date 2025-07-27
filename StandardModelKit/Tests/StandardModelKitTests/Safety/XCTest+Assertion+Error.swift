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

import XCTest

/// Asserts that an expression throws an error of a specific type.
///
/// - Parameters:
///   - expression: An expression that can throw an error.
///   - file: The file in which the failure occurs.
///   - line: The line number in which the failure occurs.
///   - errorHandler: A handler for errors that `expression` throws.
func XCTAssertThrowsError<Expression, ExpectedError: Error>(
  _ expression: @autoclosure @escaping () throws -> Expression,
  file: StaticString = #filePath,
  line: UInt = #line,
  _ errorHandler: (_ error: ExpectedError) -> Void
) {
  XCTAssertThrowsError(try expression(), file: file, line: line) { error in
    guard let error = error as? ExpectedError else {
      XCTFail(
        "Threw an error, but was of type \(type(of: error)) rather than \(ExpectedError.self)."
      )
      return
    }
    errorHandler(error)
  }
}
