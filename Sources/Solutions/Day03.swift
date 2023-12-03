import Foundation

// A point represents a position in the grid.
private struct Point: Hashable, CustomStringConvertible {
  let col: Int
  let row: Int

  var description: String { return "(\(col), \(row))" }

  static func == (lhs: Point, rhs: Point) -> Bool {
    return lhs.col == rhs.col && lhs.row == rhs.row
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(col)
    hasher.combine(row)
  }

  /// Returns the neighbors of a point.
  /// - Parameter length: The length of the value in the point.
  /// - Returns: The neighbors of the point.
  func neighbors(length: Int = 1) -> Set<Point> {
    var neighbors = Set<Point>()

    for row in (self.row - 1)...(self.row + 1) {
      for col in (self.col - 1)...(self.col + length) {
        if row == self.row && col >= self.col && col <= self.col + length - 1 {
          // Skp the point (or number) itself
          continue
        }
        neighbors.insert(Point(col: col, row: row))
      }
    }

    return neighbors
  }
}

/// An engine number is a number in the grid.
private struct EngineNumber: CustomStringConvertible {
  let number: Int
  let start: Point

  var description: String { return "\(number) at \(start)" }

  var neighbors: Set<Point> {
    return start.neighbors(length: String(number).count)
  }
}

/// An engine symbol is a symbol in the grid.
private struct EngineSymbol: Hashable, CustomStringConvertible {
  let symbol: Character
  let start: Point

  var description: String { return "\(symbol) at \(start)" }
  var neighbors: Set<Point> { return start.neighbors() }

  static func == (lhs: EngineSymbol, rhs: EngineSymbol) -> Bool {
    return lhs.symbol == rhs.symbol && lhs.start == rhs.start
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(symbol)
    hasher.combine(start)
  }
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
    for (row, line) in contents.split(separator: "\n").enumerated() {
      var numberPartials: [String] = []
      for (col, character) in line.enumerated() {
        if character.isNumber {
          numberPartials.append(String(character))
          if col < line.count - 1 { continue }
        } else if character != "." {
          let start = Point(col: col, row: row)
          symbols[start] = EngineSymbol(symbol: character, start: start)
        }

        if !numberPartials.isEmpty {
          // Take into account the case where the number is at the end of the
          // line.
          var start = Point(col: col, row: row)
          if col == line.count - 1 && character.isNumber {
            start = Point(col: col - numberPartials.count + 1, row: row)
          } else {
            start = Point(col: col - numberPartials.count, row: row)
          }

          // Add the ecolisting number to the list
          let number = Int(numberPartials.joined())!
          numbers[start] = EngineNumber(number: number, start: start)
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
      .reduce(0) { $0 + $1.number }

    return String(result)
  }

  /// Computes the solution for the second part of Day 3.
  ///
  /// The solution for the second part is filtering all gears (asterisks
  /// contiguous to exactly two numbers), find their gear ratio (multiplying the
  /// numbers together) and adding all of them together.
  ///
  /// - Returns: the solution as a string.
  override func secondPart() throws -> String {
    let input = Input(path: inputPath)

    // Map each symbol to their contiguous numbers
    var candidates: [EngineSymbol: [EngineNumber]] = [:]
    for number in input.numbers.values {
      let neighbors = number.neighbors
      for symbol in neighbors.compactMap({ input.symbols[$0] }) {
        if candidates[symbol] == nil { candidates[symbol] = [] }
        candidates[symbol]?.append(number)
      }
    }

    // Filter the gears and compute the result
    let result =
      candidates
      .filter { $0.key.symbol == "*" && $0.value.count == 2 }
      .values
      .map { $0[0].number * $0[1].number }
      .reduce(0, +)

    return String(result)
  }
}
