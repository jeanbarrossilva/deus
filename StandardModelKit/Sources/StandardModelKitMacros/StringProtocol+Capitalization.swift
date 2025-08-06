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

import Foundation

extension StringProtocol where SubSequence == Substring {
  /// Replaces all occurrences of substrings which match the given pattern up until the specified
  /// amount of times. The capitalization of each match is applied to the `replacement`; therefore,
  /// whether the `replacement` will be capitalized or uncapitalized depends on the match being
  /// either.
  ///
  /// - Parameters:
  ///   - pattern: Pattern of the substrings to be replaced.
  ///   - replacement: String by which the substrings matching the pattern will be replaced. Its
  ///     capitalization is disregarded, given that it will be changed to match that of the
  ///     substring it replaces.
  ///   - maxReplacementCount: Maximum amount of replacements. If this many replacements have been
  ///     performed and there still are remaining matches in this string, these will be left
  ///     unchanged.
  /// - Returns: A `String` with the substrings matching the `pattern` replaced by the given
  ///   `replacement` with the same capitalization as that of the substring which was replaced by
  ///   it.
  /// - Throws: If the `pattern` includes a transformation closure that throws an error.
  public func replacingWithCapitalization<Replacement: StringProtocol>(
    _ pattern: some RegexComponent<Replacement>,
    by replacement: some StringProtocol,
    maxReplacements maxReplacementCount: Int = .max
  ) throws -> String {
    guard try maxReplacementCount > 0 && pattern.regex.wholeMatch(in: replacement.string) == nil
    else { return string }
    var replaced = self[...]
    var replacementCount = 0
    var lastMatchEndIndex = replaced.startIndex
    while replacementCount < maxReplacementCount {
      guard
        let match = replaced[replaced.index(lastMatchEndIndex, offsetBy: 0)...].firstMatch(
          of: pattern
        )
      else { break }
      var replacementWithCapitalization =
        if replacement.isEmpty { replacement.string } else if match.output.isLocalizedCapitalized {
          String(replacement[replacement.startIndex]).localizedCapitalized
        } else { String(replacement[replacement.startIndex]).localizedUncapitalized }
      if replacement.count > 1 {
        replacementWithCapitalization +=
          replacement[replacement.index(after: replacement.startIndex)...]
      }
      lastMatchEndIndex = match.endIndex
      replaced.removeSubrange(match.range)
      replaced.insert(contentsOf: replacementWithCapitalization, at: match.startIndex)
      replacementCount += 1
    }
    return replaced.string
  }
}

extension StringProtocol {
  /// Uncapitalized representation of this string.
  fileprivate var localizedUncapitalized: String {
    guard !isEmpty else { return string }
    let initialString = String(self[startIndex])
    guard initialString.isLocalizedCapitalized else { return string }
    var uncapitalized = initialString.localizedLowercase
    if count > 1 { uncapitalized += self[index(after: startIndex)...] }
    return uncapitalized
  }

  /// This value itself if it is of type `String` or its conversion into a `String`.
  fileprivate var string: String { self as? String ?? .init(self) }

  /// Whether this string is localized according to the current locale.
  fileprivate var isLocalizedCapitalized: Bool { self == localizedCapitalized }
}
