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
private struct Graph: Hashable {
  private var id: String
  private var nodes: [String: (String, String)] = [:]
  var current: String = ""

  init(start: String, nodes: [String: (String, String)] = [:]) {
    self.id = start
    self.current = start
    self.nodes = nodes
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Graph, rhs: Graph) -> Bool {
    lhs.id == rhs.id
  }

  /// Parse the input and create a graph from it
  ///
  /// - Parameter input: the input string for the graph.
  /// - Returns: the graph created from the input.
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

  /// Generate as many different graphs as starting nodes in the input
  static func parseGhosts(_ input: String, reference: Graph? = .none) -> [Graph] {
    let reference = reference ?? Graph.fromInput(input)
    let ghosts = reference.getStarts().map { Graph(start: $0, nodes: reference.nodes) }
    return ghosts
  }

  /// Add a new node to the graph
  mutating func addNode(from: String, left: String, right: String) {
    nodes[from] = (left, right)
  }

  /// Get all the starting nodes
  func getStarts() -> [String] {
    nodes.keys.filter { $0.hasSuffix("A") }
  }

  /// Check if the current node is a destination one
  func isOver() -> Bool {
    current.hasSuffix("Z")
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
  var ghosts: [Graph]

  init(instructions: Instructions, graph: Graph, ghosts: [Graph]) {
    self.instructions = instructions
    self.graph = graph
    self.ghosts = ghosts
  }

  /// Creates an input instance from a given file path.
  /// - Parameter path: The path to the file containing the input.
  init(path: String) {
    let contents = try! String(contentsOfFile: path)
    let parts = contents.split(separator: "\n\n")

    let instructions = Instructions(input: String(parts[0]))
    let graph = Graph.fromInput(String(parts[1]))
    let ghosts = Graph.parseGhosts(String(parts[1]), reference: .some(graph))

    self.init(instructions: instructions, graph: graph, ghosts: ghosts)
  }
}

/// Compute the Greatest Common Divisor of two numbers.
public func gcd(_ x: Int, _ y: Int) -> Int {
  var a = 0
  var b = max(x, y)
  var r = min(x, y)

  while r != 0 {
    a = b
    b = r
    r = a % b
  }
  return b
}

/// Compute the Least Common Multiple of two numbers.
public func lcm(_ x: Int, _ y: Int) -> Int {
  return x / gcd(x, y) * y
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

  /// Computes the solution for the second part of Day 8.
  ///
  /// The input is a set of graphs, each one representing a different ghost.
  /// Each ghost follows the same instructions, but they start from different
  /// nodes. The solution is the number of steps it takes for all the ghosts to
  /// reach a destination node at once.
  ///
  /// To compute this, we can simply count the individual steps to a destination
  /// cell, and then compute the least common multiple of all those steps.
  ///
  /// - Returns: the solution as a string.
  override func secondPart() throws -> String {
    var input = Input(path: inputPath)
    var steps = [Graph: Int]()

    var step = 0
    while !input.ghosts.allSatisfy(steps.keys.contains) {
      let direction = input.instructions.next()
      step += 1

      input.ghosts.indices.forEach {
        if !steps.keys.contains(input.ghosts[$0]) {
          input.ghosts[$0].move(direction)
          if input.ghosts[$0].isOver() {
            steps[input.ghosts[$0]] = step
          }
        }
      }
    }

    // Compute the least common multiple of all the steps needed
    let result = steps.values.reduce(1, lcm)

    return String(result)
  }
}
