import Foundation

/// A direction in the graph can be left or right
private enum Direction {
  case left
  case right
}

/// A set of instructions is a circular array of directions
private struct Instructions {
  private let directions: [Direction]
  private var current: Int = 0

  init(directions: [Direction]) {
    self.directions = directions
    self.current = 0
  }

  init(input: String) {
    self.init(directions: input.map { $0 == "L" ? .left : .right })
  }

  /// Get the next direction to follow
  mutating func next() -> Direction {
    defer { current = (current + 1) % directions.count }
    return directions[current]
  }
}

/// A graph is a set of nodes, each one with two children
private struct Graph {
  private var nodes: [String: (String, String)] = [:]
  var current: String = ""

  init(start: String) {
    self.current = start
  }

  static func fromInput(_ input: String) -> Graph {
    let pattern = #/(\w+) = \((\w+), (\w+)\)/#

    var graph = Graph(start: "AAA")
    for line in input.split(separator: "\n") {
      if let result = try? pattern.wholeMatch(in: String(line)) {
        graph.addNode(
          from: String(result.1),
          left: String(result.2),
          right: String(result.3)
        )
      } else {
        fatalError("Could not parse line: \(line)")
      }
    }

    return graph
  }

  /// Add a new node to the graph
  mutating func addNode(from: String, left: String, right: String) {
    nodes[from] = (left, right)
  }

  /// Get the next node to visit
  func get(_ direction: Direction) -> String {
    switch direction {
    case .left: return nodes[current]!.0
    case .right: return nodes[current]!.1
    }
  }

  /// Move to the next node to visit
  mutating func move(_ direction: Direction) {
    current = get(direction)
  }
}

/// The input is a set of instructions and a graph.
private struct Input {
  var instructions: Instructions
  var graph: Graph

  init(instructions: Instructions, graph: Graph) {
    self.instructions = instructions
    self.graph = graph
  }

  /// Creates an input instance from a given file path.
  /// - Parameter path: The path to the file containing the input.
  init(path: String) {
    let contents = try! String(contentsOfFile: path)
    let parts = contents.split(separator: "\n\n")

    self.init(
      instructions: Instructions(input: String(parts[0])),
      graph: Graph.fromInput(String(parts[1]))
    )
  }
}

public class Day08: Solution {
  var defaultInputPath = "Assets/Day08/Test.txt"

  /// Initializes a Day08 instance with an optional input path.
  /// - Parameter inputPath: The path to the input file. If not provided, the
  ///  default input path will be used.
  override init(inputPath: String? = nil) {
    super.init(inputPath: inputPath ?? self.defaultInputPath)
  }

  /// Computes the solution for the first part of Day 8.
  ///
  /// Simply follow the instructions until the current node is the destination,
  /// then return the number of steps it took to get there.
  ///
  /// - Returns: the solution as a string.
  override func firstPart() throws -> String {
    var input = Input(path: inputPath)
    var steps = 0

    while input.graph.current != "ZZZ" {
      input.graph.move(input.instructions.next())
      steps += 1
    }

    return String(steps)
  }
}
