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

#ifndef Vertex_h
#define Vertex_h

#include <simd/simd.h>

/** Index at which the vertices are located in the buffer passed into the vertex shader. */
#define VERTEX_BUFFER_INDEX 0

/**
 Mathematical definition of a point at which two lines intersect, forming an angle. Meant to be
 passed in as input to a vertex shader, responsible for transforming a series of vertices into
 pixels to be displayed on a screen through a process called rasterization.
*/
typedef struct {
  /** X and Y coordinates in pixel space. */
  vector_float2 position;

  /** Red, green and blue color channels. */
  vector_float3 color;
} Vertex;

#endif /* Vertex_h */
