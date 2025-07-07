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

import MetalKit
import SwiftUI

/// Backing ``MTKView`` by which a simulated universe is displayed.
private final class ObservationNSView: MTKView {
  required convenience init(coder: NSCoder) {
    self.init(frame: CGRectZero, device: Self.createDevice())
  }

  override init(frame frameRect: CGRect, device: (any MTLDevice)?) {
    super.init(frame: frameRect, device: device)
    guard let device, let commandQueue = device.makeCommandQueue(),
      let commandBuffer = commandQueue.makeCommandBuffer(), let currentRenderPassDescriptor,
      let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(
        descriptor: currentRenderPassDescriptor
      ), let currentDrawable
    else { return }
    clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
    renderCommandEncoder.endEncoding()
    commandBuffer.present(currentDrawable)
    commandBuffer.commit()
  }

  /// Creates a default device corresponding to one of the GPUs in macOS, returning `nil` in case
  /// Metal is not supported by the running operating system. The returned ``MTLDevice`` is that
  /// which is used when this ``ObservationNSView`` is initialized with an unarchiver (i.e., via
  /// ``init(coder:)``).
  ///
  /// - Returns: The created default-GPU-based ``MTLDevice`` or `nil` if Metal is unsupported.
  static func createDevice() -> (any MTLDevice)? { MTLCreateSystemDefaultDevice() }
}

/// ``View`` by which a simulated universe is displayed.
private struct ObservationView: NSViewRepresentable {
  /// ``GeometryProxy`` by which the frame of the backing ``MTKView`` is defined.
  let geometry: GeometryProxy

  func makeNSView(context: Context) -> MTKView {
    ObservationNSView(frame: geometry.frame(in: .global), device: ObservationNSView.createDevice())
  }

  func updateNSView(_ nsView: MTKView, context: Context) {}
}

struct ContentView: View {
  var body: some View { GeometryReader { geometry in ObservationView(geometry: geometry) } }
}

#Preview { ContentView() }
