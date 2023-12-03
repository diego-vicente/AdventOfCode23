import Foundation

// A point represents a position in the grid.
private struct Point: Hashable, CustomStringConvertible {
  let x: Int
  let y: Int

  var description: String { return "(\(x), \(y))" }

  static func == (lhs: Point, rhs: Point) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(x)
    hasher.combine(y)
  }

  /// Returns the neighbors of a point.
  /// - Parameter length: The length of the value in the point.
  /// - Returns: The neighbors of the point.
  func neighbors(length: Int = 1) -> Set<Point> {
    var neighbors = Set<Point>()

    for y in (self.y - 1)...(self.y + 1) {
      for x in (self.x - 1)...(self.x + length) {
        if y == self.y && x >= self.x && x <= self.x + length - 1 {
          // Skp the point (or number) itself
          continue
        }
        neighbors.insert(Point(x: x, y: y))
      }
    }

    return neighbors
  }
}

/// An engine number is a number in the grid.
private struct EngineNumber: CustomStringConvertible {
  let value: Int
  let start: Point

  var description: String { return "\(value) at \(start)" }

  var neighbors: Set<Point> {
    return start.neighbors(length: String(value).count)
  }
}

/// An engine symbol is a symbol in the grid.
private struct EngineSymbol: CustomStringConvertible {
  let symbol: Character
  let start: Point

  var description: String { return "\(symbol) at \(start)" }
  var neighbors: Set<Point> { return start.neighbors() }
}

/// The input is a representation of the grid.
private struct Input {
  let numbers: [Point: EngineNumber]
  let symbols: [Point: EngineSymbol]

  init(numbers: [Point: EngineNumber], symbols: [Point: EngineSymbol]) {
    self.numbers = numbers
    self.symbols = symbols
  }

  /// Creates an input instance from a given file path.
  /// - Parameter path: The path to the file containing the input.
  init(path: String) {
    let contents = try! String(contentsOfFile: path)

    var numbers: [Point: EngineNumber] = [:]
    var symbols: [Point: EngineSymbol] = [:]
    for (y, line) in contents.split(separator: "\n").enumerated() {
      var numberPartials: [String] = []
      for (x, character) in line.enumerated() {
        if character.isNumber {
          numberPartials.append(String(character))
          if x < line.count - 1 { continue }
        } else if character != "." {
          let start = Point(x: x, y: y)
          symbols[start] = EngineSymbol(symbol: character, start: start)
        }

        if !numberPartials.isEmpty {
          // Take into account the case where the number is at the end of the
          // line.
          var start = Point(x: x, y: y)
          if x == line.count - 1 && character.isNumber {
            start = Point(x: x - numberPartials.count + 1, y: y)
          } else {
            start = Point(x: x - numberPartials.count, y: y)
          }

          // Add the existing number to the list
          let number = Int(numberPartials.joined())!
          numbers[start] = EngineNumber(value: number, start: start)
          numberPartials = []
        }
      }
    }

    self.init(numbers: numbers, symbols: symbols)
  }
}

public class Day03: Solution {
  var defaultInputPath = "Assets/Day03/Test.txt"

  /// Initializes a Day03 instance with an optional input path.
  /// - Parameter inputPath: The path to the input file. If not provided, the
  ///  default input path will be used.
  override init(inputPath: String? = nil) {
    super.init(inputPath: inputPath ?? self.defaultInputPath)
  }

  /// Computes the solution for the first part of Day 3.
  ///
  /// The solution for the first part is adding all the numbers in the grid that
  /// have a symbol in a contiguous position.
  ///
  /// - Returns: the solution as a string.
  override func firstPart() throws -> String {
    let input = Input(path: inputPath)

    let result = input.numbers.values
      .filter { n in n.neighbors.contains { input.symbols[$0] != nil } }
      .reduce(0) { $0 + $1.value }

    return String(result)
  }
}
