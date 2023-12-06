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
  var offsets: [(Range, Int)]

  init() {
    self.offsets = []
  }

  /// Adds a range to the mapping.
  ///
  /// - Parameters:
  ///   - source: The source element ID.
  ///   - destination: The destination element ID.
  ///   - steps: The number of steps between the source and destination.
  mutating func addRange(from source: Int, to destination: Int, steps: Int) {
    let offset = destination - source
    let end = source + steps - 1
    offsets.append((Range(from: source, to: end), offset))
  }

  /// Returns the destination element for a given source element.
  ///
  /// - Parameter key: The source element.
  /// - Returns: The destination element.
  func get(key: From) -> To {
    for (range, offset) in offsets {
      if range.contains(key.id) {
        return To(id: key.id + offset)
      }
    }
    return To(id: key.id)
  }
}

/// The almanac contains all the information needed to compute the location of
/// a seed.
private struct Almanac {
  let seeds: [Seed]
  var soilMap: Mapping<Seed, Soil>
  var fertilizerMap: Mapping<Soil, Fertilizer>
  var waterMap: Mapping<Fertilizer, Water>
  var lightMap: Mapping<Water, Light>
  var temperatureMap: Mapping<Light, Temperature>
  var humidityMap: Mapping<Temperature, Humidity>
  var locationMap: Mapping<Humidity, Location>

  init(
    seeds: [Seed],
    soilMap: Mapping<Seed, Soil>,
    fertilizerMap: Mapping<Soil, Fertilizer>,
    waterMap: Mapping<Fertilizer, Water>,
    lightMap: Mapping<Water, Light>,
    temperatureMap: Mapping<Light, Temperature>,
    humidityMap: Mapping<Temperature, Humidity>,
    locationMap: Mapping<Humidity, Location>
  ) {
    self.seeds = seeds
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
      .map({ Seed(id: Int($0)!) })

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
}
