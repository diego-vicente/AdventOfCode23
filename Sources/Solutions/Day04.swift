import Foundation

/// A scratch card has an ID and the numbers to play it.
///
/// The numbers are divided into two sets: the winning numbers and the numbers
/// the player scratched.
private struct Card {
  let id: Int
  let winningNumbers: Set<Int>
  let scratchNumbers: Set<Int>

  static func fromInput(_ input: String) -> Card {
    let pattern = #/Card ([\d\s]+): ([\d\s]+) \| ([\d\s]+)/#

    if let result = try? pattern.wholeMatch(in: input) {
      return Card(
        id: Int(result.1.trimmingCharacters(in: .whitespaces))!,
        winningNumbers: Set(result.2.split(separator: " ").map { Int($0)! }),
        scratchNumbers: Set(result.3.split(separator: " ").map { Int($0)! })
      )
    } else {
      fatalError("Could find game ID: \(input)")
    }
  }

  /// The matching numbers of a card are winning numbers that were scratched.
  var matchingNumbers: Set<Int> {
    winningNumbers.intersection(scratchNumbers)
  }

  /// The number of points is 1 if there is one winner, and gets doubled every
  /// time a winning number appears in the scratched ones.
  var points: Int {
    matchingNumbers.isEmpty
      ? 0 : Int(exactly: pow(Double(2), Double(matchingNumbers.count - 1)))!
  }

}

/// The input is a representation of the grid.
private struct Input {
  let cards: [Card]

  init(cards: [Card]) {
    self.cards = cards
  }

  /// Creates an input instance from a given file path.
  /// - Parameter path: The path to the file containing the input.
  init(path: String) {
    let contents = try! String(contentsOfFile: path)

    let cards =
      contents
      .split(separator: "\n")
      .map { Card.fromInput(String($0)) }

    self.init(cards: cards)
  }
}

public class Day04: Solution {
  var defaultInputPath = "Assets/Day04/Test.txt"

  /// Initializes a Day04 instance with an optional input path.
  /// - Parameter inputPath: The path to the input file. If not provided, the
  ///  default input path will be used.
  override init(inputPath: String? = nil) {
    super.init(inputPath: inputPath ?? self.defaultInputPath)
  }

  /// Computes the solution for the first part of Day 4.
  ///
  /// The solution for the first part is computing all the points of the cards
  /// and adding them together.
  ///
  /// - Returns: the solution as a string.
  override func firstPart() throws -> String {
    let input = Input(path: inputPath)
    let result = input.cards.map { $0.points }.reduce(0, +)
    return String(result)
  }

  /// Computes the solution for the second part of Day 4.
  ///
  /// To compute the solution, we keep track of the number of copies of each
  /// card in a dictionary and we iterate the original sequence to update it
  /// accordingly. Eventually, we simple count the number of copies in the
  /// dictionary.
  ///
  /// - Returns: the solution as a string.
  override func secondPart() throws -> String {
    let input = Input(path: inputPath)

    var copies = [Int: Int]()
    for card in input.cards {
      // There is always one copy of the card provided
      copies[card.id, default: 0] += 1

      guard !card.matchingNumbers.isEmpty else { continue }

      // If the card has at least a winner, add the copies to the following
      // cards. Take into account that there can be several copies of the
      // current card.
      for offset in 1...card.matchingNumbers.count {
        copies[card.id + offset, default: 0] += copies[card.id]!
      }
    }

    return String(copies.values.reduce(0, +))
  }
}
