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

// ===-------------------------------------------------------------------------------------------===
// Written entirely or modified partially by Anthropic Claude Sonnet 4.
// ===-------------------------------------------------------------------------------------------===

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `DiscreteQuarkTester` macro that generates Swift Testing test cases
/// for different quark types and colors based on the provided configuration.
public struct DiscreteQuarkTesterMacro: MemberMacro {
  /// Generates test case functions for each combination of quark types and colors.
  ///
  /// This method validates the base name contains exactly one occurrence of "quark",
  /// then creates individual test functions for each quark flavor and color combination.
  /// Each test function includes the appropriate quark instantiation and body substitution.
  ///
  /// - Parameters:
  ///   - node: The attribute syntax node containing the macro invocation
  ///   - declaration: The declaration to which the macro is attached
  ///   - context: The macro expansion context for diagnostics and other operations
  /// - Returns: Array of generated test function declarations
  /// - Throws: MacroExpansionError if validation fails or expansion encounters errors
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard case .argumentList(let arguments) = node.arguments else {
      let diagnostic = Diagnostic(
        node: node,
        message: MacroExpansionErrorMessage(
          "Expected labeled argument list for @DiscreteQuarkTester macro. Usage: "
            + "@DiscreteQuarkTester(derivingNameFrom: \"...\", ofTypes: [...], colored: [...], as: \"...\")"
        )
      )
      context.diagnose(diagnostic)
      throw MacroExpansionError.invalidArguments("Expected argument list")
    }
    let parsedArguments: ParsedArguments
    do { parsedArguments = try parseArguments(from: arguments, context: context) } catch {
      if let expansionError = error as? MacroExpansionError {
        let diagnostic = Diagnostic(
          node: node,
          message: MacroExpansionErrorMessage(expansionError.description)
        )
        context.diagnose(diagnostic)
      }
      throw error
    }
    do { try validateBaseName(parsedArguments.baseName, node: node, in: context) } catch {
      throw error
    }
    var testFunctions: [DeclSyntax] = []
    for quarkType in parsedArguments.types {
      let testFunctionsForType = try generateTestFunctions(
        for: quarkType,
        colors: parsedArguments.colors,
        baseName: parsedArguments.baseName,
        body: parsedArguments.body
      )
      testFunctions.append(contentsOf: testFunctionsForType)
    }
    return testFunctions
  }
}

// MARK: - Diagnostic Messages

/// Represents diagnostic messages for macro expansion errors.
private struct MacroExpansionErrorMessage: DiagnosticMessage {
  /// The diagnostic message text
  let message: String

  /// The diagnostic ID for categorization
  let diagnosticID: MessageID

  /// The severity level of the diagnostic
  let severity: DiagnosticSeverity

  /// Creates a new diagnostic message with error severity.
  ///
  /// - Parameter message: The error message to display
  init(_ message: String) {
    self.message = message
    self.diagnosticID = MessageID(domain: "DiscreteQuarkTesterMacro", id: "expansion-error")
    self.severity = .error
  }
}

// MARK: - Supporting Types

/// Container for parsed macro arguments.
private struct ParsedArguments {
  /// Base name for generating test function names
  let baseName: String

  /// Array of quark types to test
  let types: [QuarkTypeInfo]

  /// Array of colors to apply to each quark
  let colors: [ColorInfo]

  /// Test body template with placeholders
  let body: String
}

/// Represents a quark type with its associated flavors.
private struct QuarkTypeInfo {
  /// The main type (up or down)
  let mainType: String

  /// Available flavors for this type
  let flavors: [String]
}

/// Represents a color for quark testing.
private struct ColorInfo {
  /// The color name
  let name: String
}

/// Errors that can occur during macro expansion.
private enum MacroExpansionError: Error, CustomStringConvertible {
  /// Indicates that the macro arguments are malformed or incomplete.
  case invalidArguments(String)

  /// Indicates that the base name doesn't meet the "quark" occurrence requirements.
  case invalidBaseName(String)

  /// Indicates that a specified quark type is not supported by the macro.
  case unsupportedQuarkType(String)

  /// Indicates that the macro was attached to an inappropriate declaration type.
  case invalidAttachment(String)

  /// Indicates that required arguments are missing from the macro invocation.
  case missingRequiredArguments([String])

  /// Indicates that an argument has an unexpected type or format.
  case argumentTypeMismatch(String, expected: String, actual: String)

  var description: String {
    switch self {
    case .invalidArguments(let message): return "Invalid arguments: \(message)"
    case .invalidBaseName(let message): return "Invalid base name: \(message)"
    case .unsupportedQuarkType(let message): return "Unsupported quark type: \(message)"
    case .invalidAttachment(let message): return "Invalid attachment: \(message)"
    case .missingRequiredArguments(let arguments):
      let argumentList = arguments.joined(separator: ", ")
      return "Missing required arguments: \(argumentList)"
    case .argumentTypeMismatch(let argument, let expected, let actual):
      return "Argument '\(argument)' type mismatch: expected \(expected), got \(actual)"
    }
  }
}

// MARK: - Argument Parsing

extension DiscreteQuarkTesterMacro {
  /// Parses macro arguments from the syntax tree.
  ///
  /// Extracts and validates the base name, quark types, colors, and body template
  /// from the macro invocation arguments. Provides detailed diagnostics for missing
  /// or malformed arguments.
  ///
  /// - Parameters:
  ///   - arguments: The labeled expression list from the macro invocation
  ///   - context: Macro expansion context for emitting diagnostics
  /// - Returns: Parsed arguments structure
  /// - Throws: MacroExpansionError if parsing fails
  private static func parseArguments(
    from arguments: LabeledExprListSyntax,
    context: some MacroExpansionContext
  ) throws -> ParsedArguments {
    var baseName: String?
    var types: [QuarkTypeInfo] = []
    var colors: [ColorInfo] = []
    var body: String?
    var foundArguments: Set<String> = []
    for argument in arguments {
      guard let label = argument.label?.text else {
        let diagnostic = Diagnostic(
          node: argument,
          message: MacroExpansionErrorMessage(
            "Unlabeled argument not allowed. All arguments must be labeled "
              + "(derivingNameFrom:, ofTypes:, colored:, as:)"
          )
        )
        context.diagnose(diagnostic)
        continue
      }
      foundArguments.insert(label)
      switch label {
      case "derivingNameFrom":
        do { baseName = try extractStringLiteral(from: argument.expression) } catch {
          let diagnostic = Diagnostic(
            node: argument.expression,
            message: MacroExpansionErrorMessage(
              "'derivingNameFrom' must be a string literal containing the base test name"
            )
          )
          context.diagnose(diagnostic)
          throw MacroExpansionError.argumentTypeMismatch(
            "derivingNameFrom",
            expected: "String literal",
            actual: "non-string expression"
          )
        }
      case "ofTypes":
        do { types = try parseQuarkTypes(from: argument.expression, context: context) } catch {
          let diagnostic = Diagnostic(
            node: argument.expression,
            message: MacroExpansionErrorMessage(
              "'ofTypes' must be an array of QuarkType values like [.up([.charm, .top]), "
                + ".down([.strange])] or QuarkType.allCases"
            )
          )
          context.diagnose(diagnostic)
          throw error
        }
      case "colored":
        do { colors = try parseColors(from: argument.expression, context: context) } catch {
          let diagnostic = Diagnostic(
            node: argument.expression,
            message: MacroExpansionErrorMessage(
              "'colored' must be an array of Color values like [.red, .green, .blue] or "
                + "Color.allCases"
            )
          )
          context.diagnose(diagnostic)
          throw error
        }
      case "as":
        do { body = try extractStringLiteral(from: argument.expression) } catch {
          let diagnostic = Diagnostic(
            node: argument.expression,
            message: MacroExpansionErrorMessage(
              "'as' must be a string literal containing the test body code"
            )
          )
          context.diagnose(diagnostic)
          throw MacroExpansionError.argumentTypeMismatch(
            "as",
            expected: "String literal",
            actual: "non-string expression"
          )
        }
      default:
        let diagnostic = Diagnostic(
          node: argument,
          message: MacroExpansionErrorMessage(
            "Unknown argument '\(label)'. Valid arguments are: derivingNameFrom, ofTypes, colored, "
              + "as"
          )
        )
        context.diagnose(diagnostic)
      }
    }
    let requiredArguments = ["derivingNameFrom", "ofTypes", "colored", "as"]
    let missingArguments = requiredArguments.filter { !foundArguments.contains($0) }
    if !missingArguments.isEmpty {
      let firstArgument = arguments.first
      let diagnostic = Diagnostic(
        node: Syntax(fromProtocol: firstArgument ?? arguments),
        message: MacroExpansionErrorMessage(
          "Missing required arguments: \(missingArguments.joined(separator: ", "))"
        )
      )
      context.diagnose(diagnostic)
      throw MacroExpansionError.missingRequiredArguments(missingArguments)
    }
    if types.isEmpty {
      let diagnostic = Diagnostic(
        node: Syntax(
          fromProtocol: arguments.first { $0.label?.text == "ofTypes" }?.expression ?? arguments
        ),
        message: MacroExpansionErrorMessage(
          "'ofTypes' array cannot be empty. Specify at least one quark type."
        )
      )
      context.diagnose(diagnostic)
      throw MacroExpansionError.invalidArguments("Empty types array")
    }

    if colors.isEmpty {
      let diagnostic = Diagnostic(
        node: Syntax(
          fromProtocol: arguments.first { $0.label?.text == "colored" }?.expression ?? arguments
        ),
        message: MacroExpansionErrorMessage(
          "'colored' array cannot be empty. Specify at least one color."
        )
      )
      context.diagnose(diagnostic)
      throw MacroExpansionError.invalidArguments("Empty colors array")
    }
    return ParsedArguments(baseName: baseName!, types: types, colors: colors, body: body!)
  }

  /// Extracts a string literal value from an expression.
  ///
  /// - Parameter expression: The expression potentially containing a string literal
  /// - Returns: The extracted string value
  /// - Throws: MacroExpansionError if the expression is not a string literal
  private static func extractStringLiteral(from expression: ExprSyntax) throws -> String {
    guard let stringLiteral = expression.as(StringLiteralExprSyntax.self),
      let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self)
    else { throw MacroExpansionError.invalidArguments("Expected string literal") }
    return segment.content.text
  }

  /// Parses quark type information from an array expression or member access.
  ///
  /// - Parameters:
  ///   - expression: Array expression or member access containing quark type specifications
  ///   - context: Macro expansion context for emitting diagnostics
  /// - Returns: Array of parsed quark type information
  /// - Throws: MacroExpansionError if parsing fails
  private static func parseQuarkTypes(
    from expression: ExprSyntax,
    context: some MacroExpansionContext
  ) throws -> [QuarkTypeInfo] {
    if let memberAccess = expression.as(MemberAccessExprSyntax.self),
      let baseType = memberAccess.base?.as(DeclReferenceExprSyntax.self),
      baseType.baseName.text == "QuarkType", memberAccess.declName.baseName.text == "allCases"
    {
      return [
        QuarkTypeInfo(mainType: "up", flavors: ["up", "charm", "top"]),
        QuarkTypeInfo(mainType: "down", flavors: ["down", "strange", "bottom"])
      ]
    }
    guard let arrayExpr = expression.as(ArrayExprSyntax.self) else {
      throw MacroExpansionError.argumentTypeMismatch(
        "ofTypes",
        expected: "Array literal or QuarkType.allCases",
        actual: "\(type(of: expression))"
      )
    }
    var quarkTypes: [QuarkTypeInfo] = []
    for element in arrayExpr.elements {
      if let functionCall = element.expression.as(FunctionCallExprSyntax.self),
        let calledExpression = functionCall.calledExpression.as(MemberAccessExprSyntax.self)
      {
        let mainType = calledExpression.declName.baseName.text
        guard ["up", "down"].contains(mainType) else {
          let diagnostic = Diagnostic(
            node: calledExpression,
            message: MacroExpansionErrorMessage(
              "Unknown quark type '\(mainType)'. Valid types are: .up([...]) and .down([...])"
            )
          )
          context.diagnose(diagnostic)
          throw MacroExpansionError.unsupportedQuarkType(mainType)
        }
        do {
          let flavors = try extractFlavors(from: functionCall, mainType: mainType, context: context)
          quarkTypes.append(QuarkTypeInfo(mainType: mainType, flavors: flavors))
        } catch { throw error }
      } else {
        let diagnostic = Diagnostic(
          node: element.expression,
          message: MacroExpansionErrorMessage(
            "Invalid quark type specification. Expected format like .up([.charm, .top]) or "
              + ".down([.strange, .bottom])"
          )
        )
        context.diagnose(diagnostic)
        continue
      }
    }
    return quarkTypes
  }

  /// Extracts flavor information from a function call expression.
  ///
  /// - Parameters:
  ///   - functionCall: Function call expression containing flavor specifications (e.g., .up([.charm, .top]))
  ///   - mainType: The main quark type (up or down) for validation
  ///   - context: Macro expansion context for emitting diagnostics
  /// - Returns: Array of flavor names
  /// - Throws: MacroExpansionError if extraction fails
  private static func extractFlavors(
    from functionCall: FunctionCallExprSyntax,
    mainType: String,
    context: some MacroExpansionContext
  ) throws -> [String] {
    guard let arrayArg = functionCall.arguments.first?.expression.as(ArrayExprSyntax.self) else {
      let diagnostic = Diagnostic(
        node: functionCall,
        message: MacroExpansionErrorMessage(
          "Invalid quark type format. Expected .\(mainType)([.flavor1, .flavor2, ...]) with at least one flavor"
        )
      )
      context.diagnose(diagnostic)
      throw MacroExpansionError.invalidArguments("Invalid quark type format")
    }
    if arrayArg.elements.isEmpty {
      let diagnostic = Diagnostic(
        node: arrayArg,
        message: MacroExpansionErrorMessage(
          "Flavor array cannot be empty. Specify at least one flavor for .\(mainType)([...])"
        )
      )
      context.diagnose(diagnostic)
      throw MacroExpansionError.invalidArguments("Empty flavor array")
    }
    var flavors: [String] = []
    let validUpFlavors = ["up", "charm", "top"]
    let validDownFlavors = ["down", "strange", "bottom"]
    let validFlavors = mainType == "up" ? validUpFlavors : validDownFlavors
    for element in arrayArg.elements {
      guard let memberAccess = element.expression.as(MemberAccessExprSyntax.self) else {
        let diagnostic = Diagnostic(
          node: element.expression,
          message: MacroExpansionErrorMessage(
            "Invalid flavor specification. Expected format like .charm, .top, .strange, etc."
          )
        )
        context.diagnose(diagnostic)
        continue
      }
      let flavorName = memberAccess.declName.baseName.text
      guard validFlavors.contains(flavorName) else {
        let validFlavorsList = validFlavors.map { ".\($0)" }.joined(separator: ", ")
        let diagnostic = Diagnostic(
          node: memberAccess,
          message: MacroExpansionErrorMessage(
            "Invalid flavor '\(flavorName)' for .\(mainType) type. Valid flavors are: \(validFlavorsList)"
          )
        )
        context.diagnose(diagnostic)
        continue
      }
      flavors.append(flavorName)
    }
    if flavors.isEmpty { throw MacroExpansionError.invalidArguments("No valid flavors specified") }
    return flavors
  }

  /// Parses color information from an array expression or member access.
  ///
  /// - Parameters:
  ///   - expression: Array expression or member access containing color specifications
  ///   - context: Macro expansion context for emitting diagnostics
  /// - Returns: Array of parsed color information
  /// - Throws: MacroExpansionError if parsing fails
  private static func parseColors(
    from expression: ExprSyntax,
    context: some MacroExpansionContext
  ) throws -> [ColorInfo] {
    if let memberAccess = expression.as(MemberAccessExprSyntax.self),
      let baseType = memberAccess.base?.as(DeclReferenceExprSyntax.self),
      baseType.baseName.text == "Color", memberAccess.declName.baseName.text == "allCases"
    {
      return [ColorInfo(name: "red"), ColorInfo(name: "green"), ColorInfo(name: "blue")]
    }
    guard let arrayExpr = expression.as(ArrayExprSyntax.self) else {
      throw MacroExpansionError.argumentTypeMismatch(
        "colored",
        expected: "Array literal or Color.allCases",
        actual: "\(type(of: expression))"
      )
    }
    if arrayExpr.elements.isEmpty {
      throw MacroExpansionError.invalidArguments("Colors array cannot be empty")
    }
    var colors: [ColorInfo] = []
    let validColors = ["red", "green", "blue"]
    for element in arrayExpr.elements {
      guard let memberAccess = element.expression.as(MemberAccessExprSyntax.self) else {
        let diagnostic = Diagnostic(
          node: element.expression,
          message: MacroExpansionErrorMessage(
            "Invalid color specification. Expected format like .red, .green, .blue"
          )
        )
        context.diagnose(diagnostic)
        continue
      }
      let colorName = memberAccess.declName.baseName.text
      guard validColors.contains(colorName) else {
        let validColorsList = validColors.map { ".\($0)" }.joined(separator: ", ")
        let diagnostic = Diagnostic(
          node: memberAccess,
          message: MacroExpansionErrorMessage(
            "Unknown color '\(colorName)'. Valid colors are: \(validColorsList)"
          )
        )
        context.diagnose(diagnostic)
        continue
      }
      colors.append(ColorInfo(name: colorName))
    }
    if colors.isEmpty { throw MacroExpansionError.invalidArguments("No valid colors specified") }
    return colors
  }
}

// MARK: - Validation

extension DiscreteQuarkTesterMacro {
  /// Validates that the base name contains exactly one occurrence of "quark".
  ///
  /// - Parameters:
  ///   - baseName: The base name to validate
  ///   - node: The syntax node for diagnostic positioning
  ///   - context: Macro expansion context for emitting diagnostics
  /// - Throws: MacroExpansionError if validation fails
  private static func validateBaseName(
    _ baseName: String,
    node: SyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws {
    let quarkOccurrences = baseName.matches(of: #/quark/#.ignoresCase()).count
    if quarkOccurrences == 0 {
      let diagnostic = Diagnostic(
        node: node,
        message: MacroExpansionErrorMessage(
          "Base name '\(baseName)' must contain the word 'quark' at least once. Example: "
            + "'quarkIsAParticle' or 'testQuarkBehavior'"
        )
      )
      context.diagnose(diagnostic)
      throw MacroExpansionError.invalidBaseName(
        "Base name must contain the word 'quark' at least once"
      )
    } else if quarkOccurrences > 1 {
      let diagnostic = Diagnostic(
        node: node,
        message: MacroExpansionErrorMessage(
          "Base name '\(baseName)' contains 'quark' \(quarkOccurrences) times, but it must appear "
            + "exactly once. The word 'quark' will be replaced with specific quark and color "
            + "information."
        )
      )
      context.diagnose(diagnostic)
      throw MacroExpansionError.invalidBaseName(
        "Base name must contain the word 'quark' exactly once"
      )
    }
  }
}

// MARK: - Test Generation

extension DiscreteQuarkTesterMacro {
  /// Generates test functions for a specific quark type across all specified colors.
  ///
  /// Creates individual test functions for each flavor within the quark type,
  /// combined with each specified color.
  ///
  /// - Parameters:
  ///   - quarkType: The quark type information containing flavors
  ///   - colors: Array of colors to test with
  ///   - baseName: Base name for generating function names
  ///   - body: Test body template
  /// - Returns: Array of generated test function declarations
  /// - Throws: MacroExpansionError if generation fails
  private static func generateTestFunctions(
    for quarkType: QuarkTypeInfo,
    colors: [ColorInfo],
    baseName: String,
    body: String
  ) throws -> [DeclSyntax] {
    var functions: [DeclSyntax] = []
    for flavor in quarkType.flavors {
      for color in colors {
        let functionDecl = try generateSingleTestFunction(
          flavor: flavor,
          color: color,
          baseName: baseName,
          body: body
        )
        functions.append(functionDecl)
      }
    }
    return functions
  }

  /// Generates a single test function for a specific quark flavor and color combination.
  ///
  /// - Parameters:
  ///   - flavor: The specific quark flavor name
  ///   - color: The color information
  ///   - baseName: Base name for generating the function name
  ///   - body: Test body template
  /// - Returns: Generated test function declaration
  /// - Throws: MacroExpansionError if generation fails
  private static func generateSingleTestFunction(
    flavor: String,
    color: ColorInfo,
    baseName: String,
    body: String
  ) throws -> DeclSyntax {
    let quarkStructName = "\(flavor.capitalized)Quark"
    let functionName = try baseName.replacingWithCapitalization(
      #/quark/#.ignoresCase(),
      by: color.name + quarkStructName,
      maxReplacements: 1
    )
    let functionDecl: DeclSyntax = """
      @Test
      func \(raw: functionName)() {
        let color = \(raw: color.name)
        let quark = \(raw: quarkStructName)(color: color)
        \(raw: body)
      }
      """
    return functionDecl
  }
}
