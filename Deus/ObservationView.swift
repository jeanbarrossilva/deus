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

/// `View` by which a simulated universe is displayed.
struct ObservationView: NSViewRepresentable {
  /// Proxy by which the frame of the backing `MTKView` is defined.
  let geometry: GeometryProxy

  init(framedBy geometry: GeometryProxy) { self.geometry = geometry }

  func makeNSView(context: Context) -> MTKView {
    ObservationMTKView(
      frame: geometry.frame(in: .global),
      device: ObservationMTKView.createDevice()
    )
  }

  func updateNSView(_ nsView: MTKView, context: Context) {}
}

/// Backing `MTKView` by which a simulated universe is displayed.
private final class ObservationMTKView: MTKView {
  required convenience init(coder: NSCoder) {
    self.init(frame: CGRectInfinite, device: Self.createDevice())
  }

  override init(frame frameRect: CGRect, device: (any MTLDevice)?) {
    super.init(frame: frameRect, device: device)
    clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
    enableSetNeedsDisplay = false
  }

  override func draw() {
    guard let device, let commandQueue = device.makeCommandQueue(),
      let commandBuffer = commandQueue.makeCommandBuffer(), let currentRenderPassDescriptor,
      let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(
        descriptor: currentRenderPassDescriptor
      ), let currentDrawable
    else { return }
    renderCommandEncoder.endEncoding()
    commandBuffer.present(currentDrawable)
    commandBuffer.commit()
  }

  /// Creates a default device corresponding to one of the GPUs in macOS, returning `nil` in case
  /// Metal is not supported by the running operating system. The returned device is that which is
  /// used when this ``ObservationMTKView`` is initialized with an unarchiver (i.e., via
  /// ``init(coder:)``).
  ///
  /// - Returns: The created default-GPU-based `MTLDevice` or `nil` if Metal is unsupported.
  fileprivate static func createDevice() -> (any MTLDevice)? { MTLCreateSystemDefaultDevice() }
}

#Preview { GeometryReader { geometry in ObservationView(framedBy: geometry) } }
