//
//  Collection+ChunkTests.swift
//  Deus
//
//  Created by Jean Barros Silva on 2025.06.28.
//

import Testing

struct CollectionChunkTests {
  @Test(arguments: [false, true])
  func chunkingAnEmptyCollectionReturnsAnEmptyArray(allowsPartiality: Bool) {
    #expect([Int]().chunked(into: 2, allowsPartiality: allowsPartiality) == [])
  }

  @Test(arguments: [0, -2], [false, true])
  func chunkingWithAZeroedOrNegativeSizeReturnsAnEmptyArray(size: Int, allowsPartiality: Bool) {
    #expect([2, 4].chunked(into: size, allowsPartiality: allowsPartiality) == [])
  }

  @Test(arguments: [2, 4], [false, true])
  func
    chunkingWithASizeEqualToOrGreaterThanTheCountReturnsAnArrayWhoseOnlyElementIsTheCollectionItself(
      size: Int,
      allowsPartiality: Bool
    )
  {
    #expect([2, 4].chunked(into: size, allowsPartiality: allowsPartiality) == [[2, 4]])
  }

  @Test(arguments: [false, true]) func chunksImpartially(allowsPartiality: Bool) {
    #expect(
      [2, 4, 8, 12]
        .chunked(into: 2, allowsPartiality: allowsPartiality)
        .map { chunks in .init(chunks) } == [[2, 4], [8, 12]]
    )
  }

  @Test func chunksPartially() {
    #expect(
      [2, 4, 8, 12, 16]
        .chunked(into: 2, allowsPartiality: true)
        .map { chunks in .init(chunks) } == [[2, 4], [8, 12], [16]]
    )
  }
}
