#!/bin/bash

# Get the args
# args=("$@")
# if [[ $# -ne 1 ]]; then
#   echo ""
# fi
CURRENT_DIR=$(pwd)

dirname="$(pwd)"
foldername="${dirname%"${dirname##*[!/]}"}"   # trim the surrounding "/"
foldername="${foldername##*/}"                # remove everything before the last /
foldername=${foldername:-/}                   # correct for dirname=/ case

cat << EOF > Package.swift
// swift-tools-version:5.6

import PackageDescription

extension Target {
  static func target(name: String, sources: [String], dependencies: [Target.Dependency] = []) -> Target {
    return .target(
      name: name,
      dependencies: dependencies,
      path: "Sources",
      exclude: [],
      sources: sources,
      publicHeadersPath: nil,
      cSettings: nil,
      cxxSettings: nil,
      swiftSettings: nil,
      linkerSettings: nil
    );
  }


  static func target(name: String, path: String, sources: [String], dependencies: [Target.Dependency] = []) -> Target {
    return .target(
      name: name,
      dependencies: dependencies,
      path: path,
      exclude: [],
      sources: sources,
      publicHeadersPath: nil,
      cSettings: nil,
      cxxSettings: nil,
      swiftSettings: nil,
      linkerSettings: nil
    );
  }
}

let package = Package(
  name: "$foldername",
  products: [
    .library(
      name: "$foldername",
      targets: [
        "$foldername"
      ]
    ),
    .executable(
      name: "TestApplication",
      targets: [
        "TestApplication"
      ]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.3"),
  ],
  targets: [
    .target (
      name: "$foldername",
      path: "./Sources/$foldername",
      sources: [
        "$foldername.swift"
      ],
      dependencies: [
      ]
    ),
    .executableTarget (
      name: "TestApplication",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        "$foldername",
      ]
    )
  ]
)
EOF

# Make the file structure.
SOURCE=$CURRENT_DIR/Sources
LIBRARY=$SOURCE/$foldername
TESTAPP=$SOURCE/TestApplication

mkdir $SOURCE
mkdir $LIBRARY
mkdir $TESTAPP

cat << EOF > $LIBRARY/$foldername.swift
// Template Hello World
public class $foldername {
  // Simple Hello World program.
  public static func hello_world() -> Void {
    print("Hello World!");
  }
}
EOF

cat << EOF > $TESTAPP/TestApplication.swift
// Argument parser reference: https://apple.github.io/swift-argument-parser/documentation/argumentparser/
// Import essential libraries
import ArgumentParser
import Foundation

// Import the library to test
import $foldername

@main
struct testapp: ParsableCommand {
  static let conf = CommandConfiguration(
    abstract: "Runs the tests for this library"
  )

  func validate() throws {
    // Fill this out
  }

  func run() {
    // Simple Test Application kick starter
    let test: TestApplication = TestApplication();
    test.run();
  }
}

internal class TestApplication {
  internal func run() -> Void {
    $foldername.hello_world();    // Run the basic hello world program.
  }
}
EOF
