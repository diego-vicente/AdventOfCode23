import Foundation

/// A struct representing a calibration step from the input.
struct Calibration {
  let line: String

  /// Creates a new instance from a given input line.
  /// - Parameter line: The line to be calibrated.
  init(_ line: String) {
    self.line = line.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /// Compute the calibration value for a given digit input.
  ///
  /// Returns the value of concatenating the first and last digit of a string.
  /// If there are no digits in the input, zero is returned.
  ///
  /// - Parameter input: string to be processed
  /// - Returns: the integer obtained by concatenating the first and last digit.
  private func valueWithDigits(_ input: String) -> Int {
    let digits = input.filter("0123456789".contains)
    guard digits.count > 0 else { return 0 }
    return Int(digits.prefix(1) + digits.suffix(1))!
  }

  /// Returns the calibration value.
  ///
  /// The calibration value seemed to be computed using the first and the last
  /// digit present in the original input line and concatenating them together.
  ///
  /// - Returns: The calibration value.
  func wrongValue() -> Int {
    return valueWithDigits(line)
  }

  /// Substitutes number literals with their digit representation.
  ///
  /// - Parameter input: The input to be processed.
  /// - Returns: The input with the literal values substituted.
  private func processInput(_ input: String) -> String {
    let numberLiterals = [
      ("zero", "0"),
      ("one", "1"),
      ("two", "2"),
      ("three", "3"),
      ("four", "4"),
      ("five", "5"),
      ("six", "6"),
      ("seven", "7"),
      ("eight", "8"),
      ("nine", "9"),
    ]

    var unprocessed = input
    var digits = [String]()

    while !unprocessed.isEmpty {
      for (literal, digit) in numberLiterals {
        if unprocessed.hasPrefix(digit) || unprocessed.hasPrefix(literal) {
          digits.append(digit)
          break
        }
      }

      unprocessed = String(unprocessed.dropFirst())
    }

    return digits.joined()
  }

  /// Returns the calibration value.
  ///
  /// For a given input line, the actual calibration value is computed by
  /// concatenating the first and the last digit present in the input line.
  /// However, the input line may contain number literals (for instance, "one"
  /// or "1").
  ///
  /// - Returns: the calibration value.
  func correctValue() -> Int {
    let processed = processInput(line)
    return valueWithDigits(processed)
  }
}

/// The input is an array of `Calibration` values.
struct Input {
  let calibrations: [Calibration]

  init(_ calibrations: [Calibration]) {
    self.calibrations = calibrations
  }

  /// Creates an input instance from a given file path.
  /// - Parameter path: The path to the file containing the input.
  init(path: String) {
    let contents = try! String(contentsOfFile: path)
    let calibrations =
      contents
      .split(separator: "\n")
      .filter { !$0.isEmpty }
      .map { line in Calibration(String(line)) }

    self.init(calibrations)
  }
}

/// The solution for Day 1.
public class Day01: Solution {
  var defaultInputPath = "Assets/Day01/Input.txt"

  /// Initializes a Day01 instance with an optional input path.
  /// - Parameter inputPath: The path to the input file. If not provided, the
  ///   default input path will be used.
  override init(inputPath: String? = nil) {
    super.init(inputPath: inputPath ?? self.defaultInputPath)
  }

  /// Computes the solution for the first part of Day 1.
  ///
  /// The solution for the first part is the sum of all the calibration values
  /// provided in the input.
  ///
  /// - Returns: The computed solution as a string.
  override func firstPart() -> String {
    let input = Input(path: inputPath)

    let result = input.calibrations
      .map { $0.wrongValue() }
      .reduce(0, +)

    return String(result)
  }

  /// Computes the solution for the second part of Day 1.
  ///
  /// This solution is the sum of all the calibration values provided in the
  /// input, but the calibration value now also takes number literal into
  /// account.
  ///
  /// - Returns: The computed solution as a string.
  override func secondPart() -> String {
    let input = Input(path: inputPath)

    let result = input.calibrations
      .map { $0.correctValue() }
      .reduce(0, +)

    return String(result)
  }
}
