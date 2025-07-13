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

#include <metal_stdlib>
#include "ObservationTypes.h"

using namespace metal;

/** Rasterized form of a vertex. */
struct Rasterization {
  /** X, Y, Z and W coordinates in clip space. */
  float4 position [[position]];

  /** Red, green and blue channels. */
  float3 color;
};

/**
 Vertex shader which transforms a mathematical vertex into a pixel to be displayed on the screen.
 */
vertex Rasterization rasterize(uint vertexID [[vertex_id]],
                               constant Vertex *vertices [[buffer(VERTEX_BUFFER_INDEX)]],
                               constant Uniform &uniform [[buffer(UNIFORM_BUFFER_INDEX)]]) {
  Rasterization rasterization;
  float2 pixelSpacePosition = vertices[vertexID].position.xy * uniform.scale;
  float2 viewportSize = float2(uniform.viewportSize);
  rasterization.position.xy = pixelSpacePosition / (viewportSize / 2);
  rasterization.position.z = 0;
  rasterization.position.w = 1;
  rasterization.color = vertices[vertexID].color;
  return rasterization;
}

/** Colors the given pixel. */
fragment float4 color(Rasterization rasterization [[stage_in]]) {
  return float4(0, 0, 0 / 0, 1);
}
