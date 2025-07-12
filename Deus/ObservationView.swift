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

#Preview { GeometryReader { geometry in ObservationView(framedBy: geometry) } }

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
  /// ``VERTEX_BUFFER_INDEX`` converted into an integer whose size is architecture-based.
  private static let vertexBufferIndex = Int(VERTEX_BUFFER_INDEX)

  /// ``UNIFORM_BUFFER_INDEX`` converted into an integer whose size is architecture-based.
  private static let uniformBufferIndex = Int(UNIFORM_BUFFER_INDEX)

  /// Vertices to be drawn.
  private static let vertices = [
    Vertex(position: vector_float2(x: 250, y: -250), color: vector_float3(0, 0, 0)),
    Vertex(position: vector_float2(x: -250, y: -250), color: vector_float3(0, 0, 0)),
    Vertex(position: vector_float2(x: -250, y: 250), color: vector_float3(0, 0, 0)),
    Vertex(position: vector_float2(x: 250, y: -250), color: vector_float3(0, 0, 0)),
    Vertex(position: vector_float2(x: -250, y: 250), color: vector_float3(0, 0, 0)),
    Vertex(position: vector_float2(x: 250, y: 250), color: vector_float3(0, 0, 0))
  ]

  ///
  private var renderPipelineState: (any MTLRenderPipelineState)?

  /// Queue of commands of the render pass.
  private var commandQueue: (any MTLCommandQueue)? = nil

  /// Function of the vertex shader.
  private var vertexFunction: (any MTLFunction)? = nil

  /// Buffer to which the ``vertices`` are appended.
  private var vertexBuffer: (any MTLBuffer)? = nil

  /// Buffer to which transformations on the ``vertices`` are appended.
  private var uniformBuffer: (any MTLBuffer)? = nil

  /// Function of the fragment shader.
  private var fragmentFunction: (any MTLFunction)? = nil

  required convenience init(coder: NSCoder) {
    self.init(frame: CGRectInfinite, device: Self.createDevice())
  }

  override init(frame frameRect: CGRect, device: (any MTLDevice)?) {
    super.init(frame: frameRect, device: device)
    guard let device, let commandQueue = device.makeCommandQueue(),
      let libraryURL = Bundle.main.url(forResource: "Observation", withExtension: "metallib"),
      let library = try? device.makeLibrary(URL: libraryURL),
      let vertexBuffer = device.makeBuffer(
        bytes: Self.vertices,
        length: MemoryLayout<Vertex>.stride * Self.vertices.count,
        options: .storageModeShared
      ), let vertexFunction = library.makeFunction(name: "rasterize"),
      let fragmentFunction = library.makeFunction(name: "color"),
      let pixelFormat = (layer as! CAMetalLayer?)?.pixelFormat
    else { return }
    let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
    renderPipelineDescriptor.label = "Space"
    renderPipelineDescriptor.vertexFunction = vertexFunction
    renderPipelineDescriptor.fragmentFunction = fragmentFunction
    renderPipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat
    guard
      let renderPipelineState = try? device.makeRenderPipelineState(
        descriptor: renderPipelineDescriptor
      )
    else { return }
    var uniform = Uniform(
      scale: 1,
      viewportSize: vector_uint2(UInt32(bounds.width), UInt32(bounds.height))
    )
    guard
      let uniformBuffer = device.makeBuffer(
        bytes: &uniform,
        length: MemoryLayout.size(ofValue: uniform),
        options: .storageModeShared
      )
    else { return }
    self.renderPipelineState = renderPipelineState
    self.commandQueue = commandQueue
    self.vertexFunction = vertexFunction
    self.vertexBuffer = vertexBuffer
    self.uniformBuffer = uniformBuffer
    self.fragmentFunction = fragmentFunction
    clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
    enableSetNeedsDisplay = false
  }

  override func makeBackingLayer() -> CAMetalLayer { CAMetalLayer() }

  override func draw() {
    guard let commandQueue, let commandBuffer = commandQueue.makeCommandBuffer(),
      let currentRenderPassDescriptor,
      let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(
        descriptor: currentRenderPassDescriptor
      ), let renderPipelineState, let destination = (layer as! CAMetalLayer?)?.nextDrawable()
    else { return }
    renderCommandEncoder.setRenderPipelineState(renderPipelineState)
    renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: Self.vertexBufferIndex)
    renderCommandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: Self.uniformBufferIndex)
    renderCommandEncoder.drawPrimitives(
      type: .triangle,
      vertexStart: 0,
      vertexCount: Self.vertices.count
    )
    renderCommandEncoder.endEncoding()
    commandBuffer.present(destination)
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
