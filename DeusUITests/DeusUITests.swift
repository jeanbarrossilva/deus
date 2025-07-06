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

final class DeusUITests: XCTestCase {
  @MainActor func testRenderingOfEmptyUniverse() throws {
    let app = XCUIApplication()
    app.launch()
    let window = app.windows.firstMatch
    XCTWaiter().wait(for: [
      XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: window)
    ])
    var frame = window.frame
    guard
      let screenshot =
        window.screenshot().image.cgImage(forProposedRect: &frame, context: .current, hints: nil)
    else { fatalError("Window could not be screenshot.") }
    let bytePerPixelCount = 4
    var channels =
      [UInt8](repeating: 0, count: screenshot.width * screenshot.height * bytePerPixelCount)
    guard
      let context = CGContext(
        data: &channels,
        width: screenshot.width,
        height: screenshot.height,
        bitsPerComponent: 8,
        bytesPerRow: screenshot.width * bytePerPixelCount,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
      )
    else {
      fatalError("Could not initialize context.")
    }
    context.draw(screenshot, in: frame)
    XCTAssertFalse(channels.isEmpty, "Nothing was rendered.")
    for (index, channel) in stride(
      from: channels.startIndex,
      through: channels.count / bytePerPixelCount,
      by: Int(sqrt(Float64(integerLiteral: Int64(channels.count)))) * bytePerPixelCount
    ).enumerated() {
      lazy var x = index % screenshot.width
      lazy var y = index / screenshot.width
      XCTAssertEqual(
        ["R": channels[channel], "G": channels[channel + 1], "B": channels[channel + 2]],
        ["R": 0, "G": 0, "B": 0],
        "Pixel at (\(x), \(y)) is not black."
      )
    }
  }
}
