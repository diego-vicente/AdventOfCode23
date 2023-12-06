/// An Element is any of the things taken into account in the Almanac
private class Element: Hashable, CustomStringConvertible {
  let id: Int

  var description: String {
    return "\(type(of: self))(\(id))"
  }

  required init(id: Int) {
    self.id = id
  }

  static func == (lhs: Element, rhs: Element) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

/// There are several kinds of elements
private class Seed: Element {}
private class Soil: Element {}
private class Fertilizer: Element {}
private class Water: Element {}
private class Light: Element {}
private class Temperature: Element {}
private class Humidity: Element {}
private class Location: Element {}

// A range is a pair of integers
struct Range {
  let from: Int
  let to: Int

  init(from: Int, to: Int) {
    self.from = from
    self.to = to
  }

  /// Returns true if the value is contained in the range.
  ///
  /// - Parameter value: The value to check.
  /// - Returns: true if the value is contained in the range, false otherwise.
  func contains(_ value: Int) -> Bool {
    return value >= from && value <= to
  }
}

/// A mapping tracks offset to integer ranges.
private struct Mapping<From: Element, To: Element> {
  var forwards: [(Range, Int)]
  var backwards: [(Range, Int)]

  init() {
    self.forwards = []
    self.backwards = []
  }

  /// Adds a range to the mapping.
  ///
  /// - Parameters:
  ///   - source: The source element ID.
  ///   - destination: The destination element ID.
  ///   - steps: The number of steps between the source and destination.
  mutating func addRange(from source: Int, to destination: Int, steps: Int) {
    forwards.append(
      (
        Range(from: source, to: source + steps - 1),
        destination - source
      )
    )

    backwards.append(
      (
        Range(from: destination, to: destination + steps - 1),
        source - destination
      )
    )
  }

  /// Returns the destination element for a given source element.
  ///
  /// - Parameter key: The source element.
  /// - Returns: The destination element.
  func get(key: From) -> To {
    for (range, offset) in forwards {
      if range.contains(key.id) {
        return To(id: key.id + offset)
      }
    }
    return To(id: key.id)
  }

  /// Returns the source element for a given destination element.
  ///
  /// - Parameter key: The destination element.
  /// - Returns: The source element.
  func undo(key: To) -> From {
    for (range, offset) in backwards {
      if range.contains(key.id) {
        return From(id: key.id + offset)
      }
    }
    return From(id: key.id)
  }

  func getSourceCuts() -> Set<From> {
    var cuts: Set<From> = []

    cuts.insert(From(id: 0))
    for (range, _) in forwards {
      cuts.insert(From(id: range.from))
      cuts.insert(From(id: range.to))
    }
    return cuts
  }
}

/// The almanac contains all the information needed to compute the location of
/// a seed.
private struct Almanac {
  let seeds: [Seed]
  var seedRanges: [Range]
  var soilMap: Mapping<Seed, Soil>
  var fertilizerMap: Mapping<Soil, Fertilizer>
  var waterMap: Mapping<Fertilizer, Water>
  var lightMap: Mapping<Water, Light>
  var temperatureMap: Mapping<Light, Temperature>
  var humidityMap: Mapping<Temperature, Humidity>
  var locationMap: Mapping<Humidity, Location>

  init(
    seeds: [Seed],
    seedRanges: [Range],
    soilMap: Mapping<Seed, Soil>,
    fertilizerMap: Mapping<Soil, Fertilizer>,
    waterMap: Mapping<Fertilizer, Water>,
    lightMap: Mapping<Water, Light>,
    temperatureMap: Mapping<Light, Temperature>,
    humidityMap: Mapping<Temperature, Humidity>,
    locationMap: Mapping<Humidity, Location>
  ) {
    self.seeds = seeds
    self.seedRanges = seedRanges
    self.soilMap = soilMap
    self.fertilizerMap = fertilizerMap
    self.waterMap = waterMap
    self.lightMap = lightMap
    self.temperatureMap = temperatureMap
    self.humidityMap = humidityMap
    self.locationMap = locationMap
  }

  init(input: String) {
    let chunks = input.split(separator: "\n\n")

    self.seeds = chunks[0]
      .split(separator: ": ")[1]
      .split(separator: " ")
      .map { Seed(id: Int($0)!) }

    self.seedRanges = []
    for i in stride(from: 0, to: self.seeds.count - 1, by: 2) {
      self.seedRanges.append(
        Range(
          from: self.seeds[i].id,
          to: self.seeds[i].id + self.seeds[i + 1].id)
      )
    }

    // TODO: is there a way to abstract the following code?
    self.soilMap = Mapping<Seed, Soil>()
    for line in chunks[1].split(separator: "\n")[1...] {
      let parts = line.split(separator: " ")
      guard parts.count == 3 else { fatalError("Could not parse \(line)") }
      self.soilMap.addRange(
        from: Int(parts[1])!,
        to: Int(parts[0])!,
        steps: Int(parts[2])!
      )
    }

    self.fertilizerMap = Mapping<Soil, Fertilizer>()
    for line in chunks[2].split(separator: "\n")[1...] {
      let parts = line.split(separator: " ")
      guard parts.count == 3 else { fatalError("Could not parse \(line)") }
      self.fertilizerMap.addRange(
        from: Int(parts[1])!,
        to: Int(parts[0])!,
        steps: Int(parts[2])!
      )
    }

    self.waterMap = Mapping<Fertilizer, Water>()
    for line in chunks[3].split(separator: "\n")[1...] {
      let parts = line.split(separator: " ")
      guard parts.count == 3 else { fatalError("Could not parse \(line)") }
      self.waterMap.addRange(
        from: Int(parts[1])!,
        to: Int(parts[0])!,
        steps: Int(parts[2])!
      )
    }

    self.lightMap = Mapping<Water, Light>()
    for line in chunks[4].split(separator: "\n")[1...] {
      let parts = line.split(separator: " ")
      guard parts.count == 3 else { fatalError("Could not parse \(line)") }
      self.lightMap.addRange(
        from: Int(parts[1])!,
        to: Int(parts[0])!,
        steps: Int(parts[2])!
      )
    }

    self.temperatureMap = Mapping<Light, Temperature>()
    for line in chunks[5].split(separator: "\n")[1...] {
      let parts = line.split(separator: " ")
      guard parts.count == 3 else { fatalError("Could not parse \(line)") }
      self.temperatureMap.addRange(
        from: Int(parts[1])!,
        to: Int(parts[0])!,
        steps: Int(parts[2])!
      )
    }

    self.humidityMap = Mapping<Temperature, Humidity>()
    for line in chunks[6].split(separator: "\n")[1...] {
      let parts = line.split(separator: " ")
      guard parts.count == 3 else { fatalError("Could not parse \(line)") }
      self.humidityMap.addRange(
        from: Int(parts[1])!,
        to: Int(parts[0])!,
        steps: Int(parts[2])!
      )
    }

    self.locationMap = Mapping<Humidity, Location>()
    for line in chunks[7].split(separator: "\n")[1...] {
      let parts = line.split(separator: " ")
      guard parts.count == 3 else { fatalError("Could not parse \(line)") }
      self.locationMap.addRange(
        from: Int(parts[1])!,
        to: Int(parts[0])!,
        steps: Int(parts[2])!
      )
    }
  }
}

/// The input for the problem is an Almanac.
private struct Input {
  var almanac: Almanac

  init(almanac: Almanac) {
    self.almanac = almanac
  }

  init(path: String) {
    let contents = try! String(contentsOfFile: path)
    self.almanac = Almanac(input: contents)
  }
}

/// The solution for Day 5.
class Day05: Solution {
  var defaultInputPath = "Assets/Day05/Test.txt"

  /// Initializes a Day05 instance with an optional input path.
  /// - Parameter inputPath: The path to the input file. If not provided, the
  ///  default input path will be used.
  override init(inputPath: String? = nil) {
    super.init(inputPath: inputPath ?? self.defaultInputPath)
  }

  /// Computes the solution for the first part of Day 5.
  ///
  /// The solution of the first part simply transforms a bunch of seeds into
  /// locations (using several mappings) and compute the minimum location.
  ///
  /// - Returns: the solution as a string.
  override func firstPart() throws -> String {
    let input = Input(path: inputPath)

    let result = input.almanac.seeds
      .map { input.almanac.soilMap.get(key: $0) }
      .map { input.almanac.fertilizerMap.get(key: $0) }
      .map { input.almanac.waterMap.get(key: $0) }
      .map { input.almanac.lightMap.get(key: $0) }
      .map { input.almanac.temperatureMap.get(key: $0) }
      .map { input.almanac.humidityMap.get(key: $0) }
      .map { input.almanac.locationMap.get(key: $0) }
      .map { $0.id }
      .min()!

    return String(result)
  }

  /// Computes the solution for the second part of Day 5.
  ///
  /// The solution for part two reduces the number of possible solutions by only
  /// evaluating where the intervals change; by evaluating the cuts of each type
  /// and translating them backwards. Then, we simply have to evaluate all those
  /// points that lie within the seed ranges and return the minimum.
  override func secondPart() throws -> String {
    let input = Input(path: inputPath)

    // Carry the interval cuts backwards
    let humidityCuts = Set(
      input.almanac.locationMap
        .getSourceCuts()
    )

    let temperatureCuts = Set(
      input.almanac.humidityMap
        .getSourceCuts()
    ).union(
      humidityCuts
        .map { input.almanac.humidityMap.undo(key: $0) }
    )

    let lightCuts = Set(
      input.almanac.temperatureMap
        .getSourceCuts()
    ).union(
      temperatureCuts
        .map { input.almanac.temperatureMap.undo(key: $0) }
    )

    let waterCuts = Set(
      input.almanac.lightMap
        .getSourceCuts()
    ).union(
      lightCuts
        .map { input.almanac.lightMap.undo(key: $0) }
    )

    let fertilizerCuts = Set(
      input.almanac.waterMap
        .getSourceCuts()
    ).union(
      waterCuts
        .map { input.almanac.waterMap.undo(key: $0) }
    )

    let soilCuts = Set(
      input.almanac.fertilizerMap
        .getSourceCuts()
    ).union(
      fertilizerCuts
        .map { input.almanac.fertilizerMap.undo(key: $0) }
    )

    let seedCuts = Set(
      input.almanac.soilMap
        .getSourceCuts()
    ).union(
      soilCuts
        .map { input.almanac.soilMap.undo(key: $0) }
    )

    // Evaluate the start points within the seed ranges
    let result =
      seedCuts
      .filter { c in input.almanac.seedRanges.contains { r in r.contains(c.id) } }
      .map { input.almanac.soilMap.get(key: $0) }
      .map { input.almanac.fertilizerMap.get(key: $0) }
      .map { input.almanac.waterMap.get(key: $0) }
      .map { input.almanac.lightMap.get(key: $0) }
      .map { input.almanac.temperatureMap.get(key: $0) }
      .map { input.almanac.humidityMap.get(key: $0) }
      .map { input.almanac.locationMap.get(key: $0) }
      .map { $0.id }
      .min()!

    return String(result)
  }
}
