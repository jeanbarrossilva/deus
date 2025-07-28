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
import MacroToolkit
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Attribute for a Swift Testing suite that generates cases which test the specified types of
/// quarks with the given set of colors.
public struct DiscreteQuarkTesterMacro: MemberMacro {
  /// Expression to which that of the types of quarks to be tested default when it is not provided
  /// to the macro. Encompasses each type of quark and each of its flavors: up, with up, charm and
  /// top quarks; and down, with down, strange and bottom quarks.
  ///
  /// ## Evaluation
  ///
  /// ```
  /// [.up([.up, .charm, .top]), .down([.down, .strange, .bottom])]
  /// ```
  private static let _allTypesExpression = ArrayExprSyntax(
    elements: ArrayElementListSyntax([
      ArrayElementSyntax(
        expression: FunctionCallExprSyntax(
          calledExpression: MemberAccessExprSyntax(name: "up"),
          arguments: LabeledExprListSyntax([
            LabeledExprSyntax(
              expression: ArrayExprSyntax(
                elements: ArrayElementListSyntax(
                  ["up", "charm", "top"].map { flavor in
                    ArrayElementSyntax(expression: StringLiteralExprSyntax(content: flavor))
                  }
                )
              )
            )
          ])
        )
      ),
      ArrayElementSyntax(
        expression: FunctionCallExprSyntax(
          calledExpression: MemberAccessExprSyntax(name: "down"),
          arguments: LabeledExprListSyntax([
            LabeledExprSyntax(
              expression: ArrayExprSyntax(
                elements: ArrayElementListSyntax(
                  ["down", "strange", "bottom"].map { flavor in
                    ArrayElementSyntax(expression: StringLiteralExprSyntax(content: flavor))
                  }
                )
              )
            )
          ])
        )
      )
    ])
  )

  /// Expression to which that of the colors default when it is not provided to the macro.
  /// Encompasses all three colors: red, green and blue.
  ///
  /// ## Evaluation
  ///
  /// ```
  /// [.red, .green, .blue]
  /// ```
  private static let _allColorsExpression = ArrayExprSyntax(
    elements: ArrayElementListSyntax(
      ["red", "green", "blue"].map { color in
        ArrayElementSyntax(expression: MemberAccessExprSyntax(name: color))
      }
    )
  )

  /// ID of the diagnostic about the base name of tests not containing the word "quark" or doing so
  /// more than once.
  private static let _unallowedQuarkWordMentionCountDiagnosticID = MessageID(
    domain: "StandardModelKitMacros",
    id: "QuarkWordMentionCount"
  )

  /// Attributes shared by all test cases.
  private static let _testCaseAttributes = AttributeListSyntax([.attribute(.init("Test"))])

  /// Function signature shared by all test cases.
  private static let _testCaseSignature = FunctionSignatureSyntax(
    parameterClause: FunctionParameterClauseSyntax(parameters: FunctionParameterListSyntax([]))
  )

  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    let arguments = try expect(node.arguments, in: node, toBeOfType: LabeledExprListSyntax.self)
    var iterator = arguments.makeIterator()
    var next: ExprSyntax? { iterator.next()?.expression }
    let baseName = try safe(expect(next, in: arguments, toBeOfType: StringLiteralExprSyntax.self))
    requireSingleMentionOfWordQuark(within: baseName, in: context)
    let types = try safe(
      expect(
        next,
        in: arguments,
        toBeOfType: ArrayExprSyntax.self,
        defaultingTo: _allTypesExpression
      ).elements,
      containing: SafeCallArgument<SafeIndirectArrayArgument<SafePropertyArgument>>.self
    )
    let colors = try safe(
      expect(
        next,
        in: arguments,
        toBeOfType: ArrayExprSyntax.self,
        defaultingTo: _allColorsExpression
      ).elements,
      containing: SafePropertyArgument.self,
    )
    let body = try safe(expect(next, in: arguments, toBeOfType: StringLiteralExprSyntax.self))
    return try types.flatMap { type in
      let structName = type.id.capitalized + "Quark"
      return try colors.map { color in
        return DeclSyntax(
          FunctionDeclSyntax(
            attributes: _testCaseAttributes,
            name: TokenSyntax(
              stringLiteral: try baseName.replacingWithCapitalization(
                #/quark/#,
                by: color.id + structName
              )
            ),
            signature: _testCaseSignature,
            body: CodeBlockSyntax(
              leftBrace: .leftBraceToken(),
              statements: CodeBlockItemListSyntax([
                CodeBlockItemSyntax(
                  stringLiteral: body.replacingOccurrences(
                    of: "$quark",
                    with: "\(structName)(\(color))"
                  )
                )
              ]),
              rightBrace: .rightBraceToken()
            )
          )
        )
      }
    }
  }

  /// Ensures that the `baseName` contains only one occurrence of "quark" (case-insensitively),
  /// diagnosing an error in case it is mentioned more than one time or none at all.
  ///
  /// - Parameters:
  ///   - baseName: String in which "quark" will be looked for.
  ///   - context: Context to which the diagnostic will be reported if there are zero or
  ///     insufficient mentions of "quark".
  private static func requireSingleMentionOfWordQuark(
    within baseName: SafeStringArgument,
    in context: any MacroExpansionContext
  ) {
    let count = baseName.matches(of: #/quark/#.ignoresCase()).count
    guard count != 1 else { return }
    var message = "\(baseName.debugDescription) should mention \"quark\""
    if count > 1 { message += " only" }
    message += " once"
    context.diagnose(
      Diagnostic(
        node: baseName.syntax!,
        message: SimpleDiagnosticMessage(
          message: message,
          diagnosticID: _unallowedQuarkWordMentionCountDiagnosticID,
          severity: .error
        )
      )
    )
  }
}
