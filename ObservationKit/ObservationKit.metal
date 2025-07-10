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
#include "Vertex.h"
#include "Uniform.h"

using namespace metal;

struct Rasterization {
  float4 clipSpacePosition [[position]];
  float3 color;
};

vertex Rasterization vertexShader(uint vertexID [[vertex_id]],
                                  constant Vertex *vertices [[buffer(VERTEX_BUFFER_INDEX)]],
                                  constant Uniform &display [[buffer(UNIFORM_BUFFER_INDEX)]]) {
  Rasterization rasterization;
  float2 pixelSpacePosition = vertices[vertexID].position.xy * display.scale;
  float2 viewportSize = float2(display.viewportSize);
  rasterization.clipSpacePosition.xy = pixelSpacePosition / (viewportSize / 2);
  rasterization.clipSpacePosition.z = 0;
  rasterization.clipSpacePosition.w = 1;
  rasterization.color = vertices[vertexID].color;
  return rasterization;
}

fragment float4 fragmentShader(Rasterization rasterization [[stage_in]]) {
  return float4(rasterization.color, 1);
}

