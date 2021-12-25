// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Igor1309Dev",
    products: [
        .executable(
            name: "Igor1309Dev",
            targets: ["Igor1309Dev"]
        )
    ],
    dependencies: [
        .package(name: "Publish", url: "https://github.com/johnsundell/publish.git", from: "0.7.0")
    ],
    targets: [
        .target(
            name: "Igor1309Dev",
            dependencies: ["Publish"]
        )
    ]
)