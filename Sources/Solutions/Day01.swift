import Foundation

/// A struct representing a calibration step from the input.
struct Calibration {
  let line: String

  private let numberLiterals = [
    "zero": "0",
    "one": "1",
    "two": "2",
    "three": "3",
    "four": "4",
    "five": "5",
    "six": "6",
    "seven": "7",
    "eight": "8",
    "nine": "9",
  ]

  /// Returns the calibration value.
  ///
  /// The calibration value seemed to be computed using the first and the last
  /// digit present in the original input line and concatenating them together.
  ///
  /// This solution use two pointers, one to the beginning and one to the end of
  /// the string.
  ///
  /// - Returns: The calibration value.
  func wrongValue() -> Int {
    var first: String?
    var second: String?

    let digits = numberLiterals.values
    for offset in 0..<line.count {
      if first == nil {
        // Check the beginning of the string for the first character
        let candidate = line.dropFirst(offset)

        checkFirst: for digit in digits {
          if candidate.hasPrefix(digit) {
            first = .some(digit)
            break checkFirst
          }
        }
      }

      if second == nil {
        // Check the end of the string for the second character
        let candidate = line.dropLast(offset)

        checkSecond: for digit in digits {
          if candidate.hasSuffix(digit) {
            second = .some(digit)
            break checkSecond
          }
        }
      }

      if first != nil && second != nil { break }
    }

    let value = (first ?? "0") + (second ?? "0")
    return Int(value)!
  }

  /// Returns the calibration value.
  ///
  /// For a given input line, the actual calibration value is computed by
  /// concatenating the first and the last digit present in the input line.
  /// However, the input line may contain number literals (for instance, "one"
  /// or "1").
  ///
  /// This solution use two pointers, one to the beginning and one to the end of
  /// the string.
  ///
  /// - Returns: the calibration value.
  func correctValue() -> Int {

    var first: String?
    var second: String?

    for offset in 0..<line.count {
      if first == nil {
        // Check the beginning of the string for the first character
        let candidate = line.dropFirst(offset)

        checkFirst: for (literal, digit) in numberLiterals {
          if candidate.hasPrefix(digit) || candidate.hasPrefix(literal) {
            first = .some(digit)
            break checkFirst
          }
        }
      }

      if second == nil {
        // Check the end of the string for the second character
        let candidate = line.dropLast(offset)

        checkSecond: for (literal, digit) in numberLiterals {
          if candidate.hasSuffix(digit) || candidate.hasSuffix(literal) {
            second = .some(digit)
            break checkSecond
          }
        }
      }

      if first != nil && second != nil { break }
    }

    let value = (first ?? "0") + (second ?? "0")
    return Int(value)!
  }
}

/// The input is an array of `Calibration` values.
private struct Input {
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
      .map { line in Calibration(line: String(line)) }

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
