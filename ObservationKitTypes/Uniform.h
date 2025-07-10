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

#ifndef Uniform_h
#define Uniform_h

#include <simd/simd.h>

/** Index at which uniforms are located in the buffer passed into the vertex shader. */
#define UNIFORM_BUFFER_INDEX 1

/** Transformation on a vertex. */
typedef struct {
  /** Factor by which the vertex is scaled relative to its size. */
  float scale;

  /** Dimensions of the area available for the rendering of the vertex. */
  vector_uint2 viewportSize;
} Uniform;

#endif /* Uniform_h */
