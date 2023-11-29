import ArgumentParser

@main
struct AdventOfCodeLauncher: ParsableCommand {
  @Option(help: "Run the solution for a specific day")
  public var day: String? = nil

  @Option(help: "Path to the input file to be solved")
  public var inputPath: String? = nil

  public mutating func run() throws {
    print("Welcome to Advent of Code 2023!")
    print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n")

    // Ask explicitly for a day if not provided
    if day == .none {
      print("Please enter which day to run the solution for: ", terminator: "")
      day = readLine()
    }

    let problem: Solvable =
      switch day {
      case .none, .some(_):
        throw LauncherError.invalidDay(
          "The day entered is not valid or has not been implemented yet"
        )
      }

    problem.run()
  }
}
