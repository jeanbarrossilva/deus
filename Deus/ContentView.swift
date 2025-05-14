//
//  ContentView.swift
//  Deus
//
//  Created by Jean Barros Silva on 12/05/25.
//

import MetalKit
import SwiftUI

/// Backing ``MTKView`` by which a simulated universe is displayed.
private final class ObservationNSView: MTKView {
  required convenience init(coder: NSCoder) {
    self.init(frame: CGRectZero, device: Self.createDevice())
  }
  
  override init(frame frameRect: CGRect, device: (any MTLDevice)?) {
    super.init(frame: frameRect, device: device)
    guard let device,
          let commandQueue = device.makeCommandQueue(),
          let commandBuffer = commandQueue.makeCommandBuffer(),
          let currentRenderPassDescriptor,
          let renderCommandEncoder =
            commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor),
          let currentDrawable
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
  static func createDevice() -> (any MTLDevice)? {
    MTLCreateSystemDefaultDevice()
  }
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
  var body: some View {
    GeometryReader { geometry in ObservationView(geometry: geometry) }
  }
}

#Preview { ContentView() }
