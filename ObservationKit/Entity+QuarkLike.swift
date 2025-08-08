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

import AppKit
import RealityKit
import StandardModel

private let mesh = MeshResource.generateSphere(radius: 0.2)

extension Entity {
  /// Converts a quark-like from the Standard Model into an `Entity`.
  ///
  /// - Parameters:
  ///   - quarkLike: Quark-like from which an `Entity` is to be initialized.
  convenience init?(_ quarkLike: some QuarkLike) {
    self.init()
    guard let materialColor = NSColor(quarkLike.color) else { return nil }
    let metal = SimpleMaterial(color: materialColor, roughness: 0.8, isMetallic: true)
    let component = ModelComponent(mesh: mesh, materials: [metal])
    name = quarkLike.symbol
    components.set(component)
  }
}

extension NSColor {
  /// Converts a color-like from the Standard Model into an `NSColor`.
  ///
  /// - Parameter colorLike: Color-like from which an `NSColor` is to be initialized.
  fileprivate convenience init?<StandardModelColorLike: SingleColorLike>(
    _ colorLike: StandardModelColorLike
  ) {
    if colorLike.is(Red.self) {
      self.init(cgColor: Self.systemRed.cgColor)
    } else if colorLike.is(Anti<Red>.self) {
      self.init(cgColor: Self.red.cgColor)
    } else if colorLike.is(Green.self) {
      self.init(cgColor: Self.systemGreen.cgColor)
    } else if colorLike.is(Anti<Green>.self) {
      self.init(cgColor: Self.green.cgColor)
    } else if colorLike.is(Blue.self) {
      self.init(cgColor: Self.systemBlue.cgColor)
    } else if colorLike.is(Anti<Blue>.self) {
      self.init(cgColor: Self.blue.cgColor)
    } else {
      self.init(named: "\(StandardModelColorLike.self)")
    }
  }
}
