import Foundation

/// A race is defined by its time to race and the current record.
private struct Race {
  let time: Int
  let record: Int

  init(time: Int, record: Int) {
    self.time = time
    self.record = record
  }

  /// The victory window is defined by start and end ms timestamps.
  ///
  /// To compute the window, we just express the input as a quadratic equation
  /// and solve it to find the roots.
  var victoryWindow: (Int, Int) {
    let a = Double(1)
    let b = Double(-time)
    let c = Double(record)

    let radical = sqrt(Double(b * b - 4 * a * c))
    let sol1 = (-b - radical) / (2 * a)
    let sol2 = (-b + radical) / (2 * a)

    // If the roots are integers, we remove that timestamp; that is a tie, not a
    // victory!
    let start = ceil(sol1) == sol1 ? sol1 + 1 : ceil(sol1)
    let end = floor(sol2) == sol2 ? sol2 - 1 : floor(sol2)

    return (Int(exactly: start)!, Int(exactly: end)!)
  }

  /// The victory width counts the integers in the victory window.
  var victoryWidth: Int {
    let (sol1, sol2) = victoryWindow
    return Int(sol2 - sol1 + 1)
  }
}

/// The input is a representation of the grid.
private struct Input {
  let races: [Race]

  init(races: [Race]) {
    self.races = races
  }

  /// Creates an input instance from a given file path.
  /// - Parameter path: The path to the file containing the input.
  init(path: String) {
    let contents = try! String(contentsOfFile: path)

    let parts = contents.split(separator: "\n")

    let times = parts[0]
      .split(separator: ":")[1]
      .trimmingCharacters(in: .whitespaces)
      .split(separator: " ")
      .map { Int($0)! }

    let records = parts[1]
      .split(separator: ":")[1]
      .trimmingCharacters(in: .whitespaces)
      .split(separator: " ")
      .map { Int($0)! }

    let races = zip(times, records)
      .map { Race(time: $0, record: $1) }

    self.init(races: races)
  }
}

public class Day06: Solution {
  var defaultInputPath = "Assets/Day06/Test.txt"

  /// Initializes a Day06 instance with an optional input path.
  /// - Parameter inputPath: The path to the input file. If not provided, the
  ///  default input path will be used.
  override init(inputPath: String? = nil) {
    super.init(inputPath: inputPath ?? self.defaultInputPath)
  }

  /// Computes the solution for the first part of Day 6.
  ///
  /// The first part consists of computing all integers between the roots of the
  /// equation that computes the distance of the race to be the record.
  ///
  /// - Returns: the solution as a string.
  override func firstPart() throws -> String {
    let input = Input(path: inputPath)
    let result = input.races.map { $0.victoryWidth }.reduce(1, *)
    return String(result)
  }

}
