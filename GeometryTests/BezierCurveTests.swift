//
//  BezierCurveTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 17/05/25.
//

import Testing

@testable import Geometry

struct BezierCurveTests {
  @Test func makesCubicBezierCurve() {
    let controller = Point(x: 0.25, y: 0.1)
    let start = Point.zero.controlled(by: controller)
    let end = Point(x: 1, y: 1).controlled(by: controller)
    let curve = BezierCurve.make(from: start, to: end)
    let points = [
      Point.zero,
      Point(x: 0.0685, y: 0.028),
      Point(x: 0.128, y: 0.056),
      Point(x: 0.1845, y: 0.09),
      Point(x: 0.244, y: 0.136),
      Point(x: 0.3125, y: 0.2),
      Point(x: 0.396, y: 0.288),
      Point(x: 0.5005, y: 0.406),
      Point(x: 0.632, y: 0.56),
      Point(x: 0.7965, y: 0.756),
      Point(x: 1, y: 1)
    ]
    for (offset, t) in stride(from: 0, to: 1, by: 0.1).enumerated() {
      let point = curve[t]
      guard offset > 0 else {
        #expect(point == points.first!)
        continue
      }
      guard offset < 10 else {
        #expect(point == points.last!)
        continue
      }
      #expect(point.isApproximate(to: points[offset]))
    }
  }
}
