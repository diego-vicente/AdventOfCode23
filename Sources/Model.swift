import Dispatch

protocol Solvable {
  func run()
}

public class Solution: Solvable {
  var inputPath: String

  init(inputPath: String) {
    self.inputPath = inputPath
  }

  func firstPart() throws -> String {
    throw LauncherError.notImplemented("The first part has not been implemented")
  }

  func secondPart() throws -> String {
    throw LauncherError.notImplemented("The second part has not been implemented")
  }

  private func time(_ block: () throws -> Void) throws -> Double {
    let start = DispatchTime.now()
    try block()
    let end = DispatchTime.now()
    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
    return Double(nanoTime) / 1_000_000_000
  }

  func run() {
    do {
      let time = try time {
        print("First part: \(try firstPart())")
      }
      print("First part took \(time) seconds to run")
    } catch LauncherError.notImplemented {
      print("First part has not been implemented yet")
    } catch {
      fatalError("Unexpected error: \(error)")
    }

    print("\n")

    do {
      let time = try time {
        print("Second part: \(try secondPart())")
      }
      print("Second part took \(time) seconds to run")
    } catch LauncherError.notImplemented {
      print("Second part has not been implemented yet")
    } catch {
      fatalError("Unexpected error: \(error)")
    }
  }
}
