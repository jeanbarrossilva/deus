//
//  BezierCurveTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 17/05/25.
//

import Testing

@testable import NewtonianKit

struct BezierCurveTests {
  let bezierCurve = BezierCurve.make(
    from: Point.zero.controlled(by: .init(x: 0, y: 3)),
    to: Point(x: 3, y: 0).controlled(by: .init(x: 3, y: 3))
  )

  @Test func getsPointAtProgressionOfCubicBezierCurve() {
    #expect(bezierCurve[0.5] == .at(x: 1.5, y: 2.25))
  }
}
