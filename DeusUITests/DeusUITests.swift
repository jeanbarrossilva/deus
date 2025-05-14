//
//  DeusUITests.swift
//  DeusUITests
//
//  Created by Jean Barros Silva on 12/05/25.
//

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
