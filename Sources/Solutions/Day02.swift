import Foundation

/// A cube can be either blue, red or green.
private enum Cube {
  case blue
  case red
  case green

  /// Parse the input into a cube color.
  static func fromInput(_ input: String) -> Cube {
    switch input {
    case "blue": return .blue
    case "red": return .red
    case "green": return .green
    default: fatalError("Unknown color: \(input)")
    }
  }
}

/// A cube set is a set of cubes, of different colors.
private struct CubeSet {
  let cubes: [(Cube, Int)]

  /// The input is a comma separated list of cube colors and their count.
  /// - Parameter input: The input to be parsed.
  /// - Returns: A cube set instance.
  static func fromInput(_ input: String) -> CubeSet {
    var cubes = [(Cube, Int)]()
    for display in input.split(separator: ",") {
      if let result = try? #/(\d+) (\w+)/#.firstMatch(in: display) {
        let cube = Cube.fromInput(String(result.2))
        let count = Int(result.1)!
        cubes.append((cube, count))
      } else {
        fatalError("Could not parse input: \(input)")
      }
    }

    return CubeSet(cubes: cubes)
  }

  /// Check if this cube set is possible under certain conditions.
  ///
  /// A cube set is possible if all the cubes in the set are under the max
  /// counts expected for each of the colors.
  ///
  /// - Parameter maxCubes: A dictionary of cube colors and their max counts.
  /// - Returns: if the cube set is possible or not.
  func isPossible(maxCubes: [Cube: Int]) -> Bool {
    cubes.allSatisfy { (cube, count) in count <= maxCubes[cube]! }
  }

  /// The power of a cube set is all the cubes multiplied together.
  func power() -> Int {
    cubes.map { (cube, count) in count }.reduce(1, *)
  }
}

/// A game is a sequence of cube sets.
///
/// Each time a game is played, the elf shows a bunch of cubes to the player (a
/// single cube set) and then puts them back in the bag. They do this several
/// times.
private struct Game {
  let id: Int
  let sets: [CubeSet]

  /// Parse the input into a game instance.
  /// - Parameter input: The input to be parsed.
  /// - Returns: A game instance.
  static func fromInput(_ input: String) -> Game {
    var id: Int
    var sets: [CubeSet]

    let components = input.split(separator: ":")
    guard components.count == 2 else {
      fatalError("Could not parse input: \(input)")
    }

    if let result = try? #/Game (\d+)/#.wholeMatch(in: components[0]) {
      id = Int(result.1)!
    } else {
      fatalError("Could find game ID: \(input)")
    }

    sets = components[1]
      .split(separator: ";")
      .map { CubeSet.fromInput(String($0)) }

    return Game(id: id, sets: sets)
  }

  /// Return if a game is possible or not.
  ///
  /// A game is possible if every time the elf showed some cubes, the number
  /// of cubes of each color was less than or equal to the max number of cubes
  /// expected.
  ///
  /// - Parameter maxCubes: A dictionary of cube colors and their max counts.
  /// - Returns: whether the game is possible or not.
  func isPossible(maxCubes: [Cube: Int]) -> Bool {
    sets.allSatisfy { $0.isPossible(maxCubes: maxCubes) }
  }

  /// Return the minimum possible cube set.
  ///
  /// For a given game, its minimum possible set is the set of cubes that
  /// that allow the game to be possible.
  ///
  /// - Returns: the minimum possible cube set.
  func minPossible() -> CubeSet {
    var minSet: [Cube: Int] = [.red: 0, .green: 0, .blue: 0]
    for cubes in sets {
      for (color, count) in cubes.cubes {
        if minSet[color]! < count {
          minSet[color] = count
        }
      }
    }

    return CubeSet(cubes: minSet.map { ($0.key, $0.value) })
  }
}

/// The input is an array of games.
private struct Input {
  let games: [Game]

  init(_ games: [Game]) {
    self.games = games
  }

  /// Creates an input instance from a given file path.
  /// - Parameter path: The path to the file containing the input.
  init(path: String) {
    let contents = try! String(contentsOfFile: path)
    let games =
      contents
      .split(separator: "\n")
      .map { Game.fromInput(String($0)) }

    self.init(games)
  }
}

public class Day02: Solution {
  var defaultInputPath = "Assets/Day02/Test.txt"

  /// Initializes a Day02 instance with an optional input path.
  /// - Parameter inputPath: The path to the input file. If not provided, the
  ///  default input path will be used.
  override init(inputPath: String? = nil) {
    super.init(inputPath: inputPath ?? self.defaultInputPath)
  }

  /// Computes the solution for the first part of Day 2.
  ///
  /// The solution for the first part is adding the IDs of all the games that
  /// are possible assuming that there are only 12 red cubes, 13 green cubes and
  /// 14 blue cubes.
  ///
  /// - Returns: the solution as a string.
  override func firstPart() throws -> String {
    let input = Input(path: inputPath)

    let maxCubes = [
      Cube.red: 12,
      Cube.green: 13,
      Cube.blue: 14,
    ]

    let result = input.games
      .filter { $0.isPossible(maxCubes: maxCubes) }
      .map { $0.id }
      .reduce(0, +)

    return String(result)
  }

  /// Computes the solution for the second part of Day 2.
  ///
  /// The solution for the second part is adding the power of all the minimum
  /// possible cube sets for each game.
  ///
  /// - Returns: the solution as a string.
  override func secondPart() throws -> String {
    let input = Input(path: inputPath)

    let result = input.games
      .map { $0.minPossible().power() }
      .reduce(0, +)

    return String(result)

  }
}
