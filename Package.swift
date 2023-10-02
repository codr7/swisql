// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "Swisql",

  products: [
    .library(
      name: "SwisqlStatic",
      type: .static,
      targets: ["Swisql"]),

    .library(
      name: "SwisqlDynamic",
      type: .dynamic,
      targets: ["Swisql"]),

    .executable(
      name: "SwisqlTests",
      targets: ["SwisqlTests"])
  ],

  dependencies: [
  ],
  
  targets: [
    .target(
      name: "Swisql",
      dependencies: [
      ]),
    
    .executableTarget(
      name: "SwisqlTests",
      dependencies: ["Swisql"]),
  ]
)
