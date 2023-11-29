# Advent of Code 2023

Another year, another repository with solutions for the [Advent of Code challenges](https://adventofcode.com/2023)! This time, the language chosen is Swift. Contrary to what common sense could indicate, I decided to not use XCode and instead program this in my text editor and use the `swift` CLI tool to build and run the solutions.

In the `Sources/Solutions` repositories contain all the interesting code to solve the challenges, while the rest of it is mainly boilerplate and some quality-of-life abstractions.

## Running the code

To run the tool, I simply run:

```shell
swift run AdventOfCode23 [--day=<DAY>] [--input=<PATH>]
```

This is the unoptimized build though; in order to generate an optimized binary you can run the following configuration:

```shell
swift run -c release AdventOfCode23 [--day=<DAY>] [--input=<PATH>]
```

In order build a binary file:

```shell
swift build -c release
```
