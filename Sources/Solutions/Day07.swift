import Foundation

/// A Card is basically an integer with extra steps.
private typealias Card = Int

extension Card {
  /// Parse a string input into a card.
  /// - Parameter input: The string input to be parsed.
  /// - Returns: The parsed card.
  fileprivate static func fromInput(_ input: String) -> Card {
    switch input {
    case "A": return 14
    case "K": return 13
    case "Q": return 12
    case "J": return 11
    case "T": return 10
    default: return Int(input)!
    }
  }
}

/// A Result is the result of a hand.
enum Result: Int, Comparable {
  case highCard = 0
  case onePair = 1
  case twoPairs = 2
  case threeOfAKind = 3
  case fullHouse = 4
  case fourOfAKind = 5
  case fiveOfAKind = 6

  static func < (lhs: Result, rhs: Result) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

/// A Hand is a set of cards with a bid.
private struct Hand: Comparable {
  let bid: Int
  let cards: [Card]

  init(bid: Int, cards: [Card]) {
    self.bid = bid
    self.cards = cards
  }

  init(input: String) {
    let parts = input.split(separator: " ")
    let bid = Int(parts[1])!
    let cards = parts[0].map { Card.fromInput(String($0)) }
    self.init(bid: bid, cards: cards)
  }

  /// The result of the hand.
  var result: Result {
    let counts = Dictionary(grouping: cards, by: { $0 })
      .mapValues { $0.count }
      .values.sorted()

    return switch counts {
    case [5]: .fiveOfAKind
    case [1, 4]: .fourOfAKind
    case [2, 3]: .fullHouse
    case [1, 1, 3]: .threeOfAKind
    case [1, 2, 2]: .twoPairs
    case [1, 1, 1, 2]: .onePair
    default: .highCard
    }
  }

  /// Compares two hands.
  ///
  /// The comparison is done by comparing the result of the hands first, and
  /// then the cards (in sequential order).
  static func < (lhs: Hand, rhs: Hand) -> Bool {
    if lhs.result != rhs.result {
      return lhs.result < rhs.result
    }

    for (leftCard, rightCard) in zip(lhs.cards, rhs.cards) {
      if leftCard != rightCard {
        return leftCard < rightCard
      }
    }

    return false
  }
}

/// The input can be several races or a single one.
private struct Input {
  let hands: [Hand]

  init(hands: [Hand]) {
    self.hands = hands
  }

  /// Creates an input instance from a given file path.
  /// - Parameter path: The path to the file containing the input.
  init(path: String) {
    let contents = try! String(contentsOfFile: path)

    let hands =
      contents
      .split(separator: "\n")
      .map { Hand(input: String($0)) }

    self.init(hands: hands)
  }
}

public class Day07: Solution {
  var defaultInputPath = "Assets/Day07/Test.txt"

  /// Initializes a Day07 instance with an optional input path.
  /// - Parameter inputPath: The path to the input file. If not provided, the
  ///  default input path will be used.
  override init(inputPath: String? = nil) {
    super.init(inputPath: inputPath ?? self.defaultInputPath)
  }

  /// Computes the solution for the first part of Day 7.
  ///
  /// The first simply sorts the list of hands to assign a rank, and then
  /// multiplies such rank by the hand's bid.
  ///
  /// - Returns: the solution as a string.
  override func firstPart() throws -> String {
    let input = Input(path: inputPath)

    let result = input
      .hands.sorted()
      .enumerated()
      .map { (rank, hand) in hand.bid * (rank + 1) }
      .reduce(0, +)

    return String(result)
  }
}
