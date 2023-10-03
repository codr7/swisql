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
    .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.14.0"),
  ],
  
  targets: [
    .target(
      name: "Swisql",
      dependencies: [
        .product(name: "PostgresNIO", package: "postgres-nio"),
      ]),
    
    .executableTarget(
      name: "SwisqlTests",
      dependencies: ["Swisql"]),
  ]
)
