import Foundation

/// A struct representing a calibration step from the input.
struct Calibration {
  let line: String

  /// Creates a new instance from a given input line.
  /// - Parameter line: The line to be calibrated.
  init(_ line: String) {
    self.line = line.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /// Returns the calibration value.
  ///
  /// The calibration value is computed using the first and the last digit
  /// present in the original input line and concatenating them together.
  ///
  /// - Returns: The calibrated value.
  func value() -> Int {
    let digits = line.filter("0123456789".contains)
    let value = Int(digits.prefix(1) + digits.suffix(1))!
    return value
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
    let calibrations = contents.split(separator: "\n").map { line in
      Calibration(String(line))
    }

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
      .map { $0.value() }
      .reduce(0, +)

    return String(result)
  }
}
